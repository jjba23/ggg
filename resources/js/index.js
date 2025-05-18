function renderSvgToImage(id, hideVectorImages = false) {
  let svg = document.getElementById(id)
  let img = document.getElementById(id + '-img')
  let canvas = document.createElement('canvas')

  let xml = new XMLSerializer().serializeToString(svg)

  let svg64 = btoa(xml)
  let b64Start = 'data:image/svg+xml;base64,'

  var image64 = b64Start + svg64

  img.onload = function() {
    canvas.getContext('2d').drawImage(img, 0, 0)
  }
  img.src = image64
  if (hideVectorImages) {
    svg.style.display = 'none'
  }
}





