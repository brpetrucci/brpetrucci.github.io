.this_dir <- function() {
  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", cmd_args, value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  }
  frame_files <- Filter(Negate(is.null), lapply(sys.frames(), function(f) f$ofile))
  if (length(frame_files) > 0) {
    return(dirname(normalizePath(frame_files[[length(frame_files)]])))
  }
  stop(
    "Could not determine this script's location. ",
    "Run it via source(\"...knit_tutorial.R\") rather than pasting its ",
    "contents directly into the console."
  )
}

# Computed once, when this file is source()d, from its own location --
# independent of whatever the calling R session's working directory is.
repo_root <- normalizePath(file.path(.this_dir(), "..", ".."))

knit_tutorial <- function(name) {
  library(rmarkdown)

  input <- file.path(repo_root, "_tutorials", "_rmd", paste0(name, ".Rmd"))
  output_file <- file.path(repo_root, "_tutorials", paste0(name, ".md"))
  
  render(
    input = input,
    output_format = md_document(
      variant = "gfm",
      preserve_yaml = TRUE,
      md_extensions = "-smart",
      pandoc_args = c(
        "--metadata=link-citations:true",
        # GFM's writer defaults to its own $`...`$ math delimiters, which the
        # site's MathJax config doesn't recognize -- force plain $...$/$$...$$
        # instead, which MathJax (see _includes/head/custom.html) does expect
        "--to=gfm-tex_math_gfm-yaml_metadata_block"
      )
    ),
    output_file = output_file
  )

  # pandoc's citeproc emits the references list as a raw HTML block, which
  # kramdown otherwise treats as opaque text -- markdown="1" tells kramdown to
  # actually parse its contents, so italics/bold/DOI links render correctly
  # instead of showing as literal *asterisks* and escaped <angle brackets>.
  # pandoc also strips markdown="1" from <details> blocks (used for
  # collapsible/dropdown sections) even when written directly in the .Rmd --
  # standard attributes like class survive, only kramdown's own is dropped.
  #
  # NB: this uses regmatches()<- rather than gsub() backreferences (\\1) --
  # on this R installation, gsub() backreference substitution is broken (it
  # drops the captured text entirely, confirmed even with R's own canonical
  # ?gsub example), so this avoids backreferences altogether.
  insert_markdown_attr <- function(text, pattern) {
    m <- gregexpr(pattern, text)
    regmatches(text, m) <- lapply(regmatches(text, m), function(matches) {
      sub(">$", ' markdown="1">', matches)
    })
    text
  }

  if (file.exists(output_file)) {
    rendered <- readLines(output_file, warn = FALSE)
    rendered <- insert_markdown_attr(rendered, '<div id="refs"[^>]*>')
    rendered <- insert_markdown_attr(rendered, '<div id="ref-[^"]*" class="csl-entry">')
    rendered <- insert_markdown_attr(rendered, '<details[^>]*>')
    writeLines(rendered, output_file)
  }
  
  # knitr writes figures relative to the input file's own directory, not
  # repo root -- copy them into place next to any static images you've put
  # there by hand (e.g. mcc_tree.svg). Copying individual files rather than
  # replacing the whole destination directory means pre-existing static
  # images in images/tutorials/<name>/ are never touched or deleted.
  generated_figs <- file.path(repo_root, "_tutorials", "_rmd", "images", "tutorials", name)
  final_figs <- file.path(repo_root, "images", "tutorials", name)
  if (dir.exists(generated_figs)) {
    dir.create(final_figs, recursive = TRUE, showWarnings = FALSE)
    generated_files <- list.files(generated_figs, full.names = TRUE)
    if (length(generated_files) > 0) {
      file.copy(generated_files, final_figs, overwrite = TRUE)
    }
    unlink(file.path(repo_root, "_tutorials", "_rmd", "images"), recursive = TRUE)
  }
  
  intermediate <- file.path(repo_root, "_tutorials", "_rmd", paste0(name, ".knit.md"))
  if (file.exists(intermediate)) file.remove(intermediate)

  # _tutorials/_rmd/ is underscore-prefixed, so Jekyll never publishes it --
  # copy the .Rmd source into files/tutorials/<name>/ (where every other
  # downloadable file already lives) so a download link can actually reach
  # it, and so that copy always matches what was just knitted
  public_dir <- file.path(repo_root, "files", "tutorials", name)
  dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
  file.copy(input, file.path(public_dir, paste0(name, ".Rmd")), overwrite = TRUE)
}