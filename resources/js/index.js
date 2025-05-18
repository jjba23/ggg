//
// a setting of `hideImages: true, hideVectorImages: false` is good for development
// since it allows you to see exactly how the image is generated, all the SVG components
// like the text, the rectangles, etc
//
// for general compatibility you may want to use `hideImages: false, hideVectorImages: true`
// since that will hide the vector images and render good old images you can simply download
//
function renderSvgToImage({ id, hideImages, hideVectorImages }) {
  let svg = document.getElementById(id)
  let xml = new XMLSerializer().serializeToString(svg)
  let svg64 = btoa(xml)
  let b64Start = 'data:image/svg+xml;base64,'
  var image64 = b64Start + svg64

  if (!hideImages) {
    let img = document.getElementById(id + '-img')
    let canvas = document.createElement('canvas')
    img.onload = function() {
      canvas.getContext('2d').drawImage(img, 0, 0)
    }
    img.src = image64
  }

  if (hideVectorImages) {
    svg.style.display = 'none'
  }
}
