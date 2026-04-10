function initGallery(base, photos, label) {
  const gallery = document.getElementById('gallery');
  photos.forEach((filename, i) => {
    const url = base + encodeURIComponent(filename);
    const div = document.createElement('div');
    div.className = 'thumb';
    const img = document.createElement('img');
    img.alt = `${label} photo ${i + 1}`;
    img.loading = 'lazy';
    img.src = url;
    img.addEventListener('load',  () => img.classList.add('loaded'));
    img.addEventListener('error', () => img.classList.add('loaded'));
    div.appendChild(img);
    div.addEventListener('click', () => openLightbox(i));
    gallery.appendChild(div);
  });

  const lightbox  = document.getElementById('lightbox');
  const lbImg     = document.getElementById('lbImg');
  const lbCounter = document.getElementById('lbCounter');
  let current = 0;

  function openLightbox(i) { current = i; showPhoto(); lightbox.classList.add('open'); document.body.style.overflow = 'hidden'; }
  function closeLightbox()  { lightbox.classList.remove('open'); document.body.style.overflow = ''; lbImg.src = ''; }
  function showPhoto()      { lbImg.src = base + encodeURIComponent(photos[current]); lbImg.alt = `${label} photo ${current + 1}`; lbCounter.textContent = `${current + 1} / ${photos.length}`; }
  function prev() { current = (current - 1 + photos.length) % photos.length; showPhoto(); }
  function next() { current = (current + 1) % photos.length; showPhoto(); }

  document.getElementById('lbClose').addEventListener('click', closeLightbox);
  document.getElementById('lbPrev').addEventListener('click', prev);
  document.getElementById('lbNext').addEventListener('click', next);
  lightbox.addEventListener('click', e => { if (e.target === lightbox) closeLightbox(); });
  document.addEventListener('keydown', e => {
    if (!lightbox.classList.contains('open')) return;
    if (e.key === 'ArrowLeft')  prev();
    if (e.key === 'ArrowRight') next();
    if (e.key === 'Escape')     closeLightbox();
  });
}
