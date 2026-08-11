(function () {
  var content = document.querySelector(".page__content");
  var menu = document.querySelector("#tutorial-toc .toc__menu");

  if (!content || !menu) {
    return;
  }

  var headings = content.querySelectorAll("h2, h3");
  var currentTopLevelItem = null;
  var currentSubList = null;

  headings.forEach(function (heading) {
    if (!heading.id) {
      return;
    }

    var link = document.createElement("a");
    link.href = "#" + heading.id;
    link.textContent = heading.textContent;

    var item = document.createElement("li");
    item.appendChild(link);

    if (heading.tagName === "H2") {
      menu.appendChild(item);
      currentTopLevelItem = item;
      currentSubList = null;
    } else if (currentTopLevelItem) {
      if (!currentSubList) {
        currentSubList = document.createElement("ul");
        currentTopLevelItem.appendChild(currentSubList);
      }
      currentSubList.appendChild(item);
    } else {
      menu.appendChild(item);
    }
  });
})();
