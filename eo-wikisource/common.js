(function () {
  "use strict";

  function onDOMChanges(callback, node, options) {
    const targetNode = node ?? document.body;
    const config = options ?? {attributes: true, childList: true, subtree: true};
    const observer = new MutationObserver(callback);
    observer.observe(targetNode, config);
    return observer;
  }

  if (mw.config.get("wgNamespaceNumber") === 104 && mw.config.get("wgAction") === "edit") {
    onDOMChanges(filterImage, $(".prp-page-image")[0]);
  }

  function filterImage() {
    const url = $("#ca-proofreadPageScanLink > a").attr("href");
    const $canvas = $("canvas");
    if ($canvas.length) {
      const canvas = $canvas[0];
      const context = canvas.getContext("2d");
      context.filter = "grayscale(1) invert(1) sepia(1)"
      const image = new Image();
      image.crossOrigin = "Anonymous";
      image.src = url;
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.drawImage(image, 0, 0);
    }
  }

  // if (mw.config.get("wgNamespaceNumber") !== 106) {  // Index namespace
  //   return;
  // }
  //
  // const api = new mw.Api();
  //
  // $(".prp-index-pagelist a[class*='prp-pagequality-']").each(function (_, e) {
  //   const $e = $(e);
  //   const pageTitle = $e.attr("title");
  //   console.log(pageTitle);
  //   checkPage(pageTitle, $e);
  // });
  //
  // function checkPage(pageTitle, $element) {
  //   // noinspection JSUnresolvedReference
  //   api.get({
  //     action: "query",
  //     titles: pageTitle,
  //     prop: "revisions",
  //     rvprop: "content",
  //     rvslots: "main",
  //   }).then(function (pageData) {
  //     const pageID = Object.keys(pageData.query.pages)[0];
  //     // noinspection JSUnresolvedReference
  //     const pageContent = pageData.query.pages[pageID].revisions[0].slots.main["*"];
  //     const regExp = /<section\s+begin="([^"]+)"\s*\/>/g;
  //     const checked = new Set();
  //     let match;
  //     while ((match = regExp.exec(pageContent)) !== null) {
  //       const title = match[1];
  //       if (checked.has(title)) {
  //         continue;
  //       }
  //       checked.add(title);
  //       // noinspection JSUnresolvedReference
  //       api.get({
  //         action: "query",
  //         titles: title,
  //         prop: "revisions",
  //         rvprop: "content",
  //         rvslots: "main",
  //       }).then(function (response) {
  //         const pageID = +Object.keys(response.query.pages)[0];
  //         if (pageID < 0) {
  //           $element.css("border", "1px dashed");
  //           $element.attr("title", $element.attr("title") + ", " + title);
  //         }
  //       });
  //     }
  //   });
  // }
})();
