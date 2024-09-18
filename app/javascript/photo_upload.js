document.addEventListener('turbo:load', function() {
  const form = document.getElementById('photo-upload-form');
  const uploadResult = document.getElementById('upload-result');
  const similarityResult = document.getElementById('similarity-result');

  if (form) {
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      const formData = new FormData(form);
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

      uploadResult.innerHTML = '<p>アップロード中...</p>';
      similarityResult.innerHTML = '';

      fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          uploadResult.innerHTML = '<div class="alert alert-success"><h3>アップロード成功</h3></div>';
          uploadResult.innerHTML += '<p>類似度を計算中...</p>';
          
          // 類似度チェックを開始
          checkSimilarity(data.photo.id);
        } else {
          throw new Error(data.errors ? data.errors.join(', ') : 'アップロードに失敗しました');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        uploadResult.innerHTML = `<div class="alert alert-danger">エラーが発生しました: ${error.message}</div>`;
      });
    });
  }

  function checkSimilarity(photoId) {
    const checkInterval = setInterval(() => {
      fetch(`/photos/${photoId}/check_similarity`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.similarity !== null) {
          clearInterval(checkInterval);
          updateSimilarityDisplay(data);
        }
      })
      .catch(error => {
        console.error('Error checking similarity:', error);
      });
    }, 2000); // 2秒ごとにチェック
  }

  function updateSimilarityDisplay(data) {
    similarityResult.innerHTML = `
      <p>類似度: ${(data.similarity * 100).toFixed(2)}%</p>
      ${data.cleared ? '<h2>チャレンジクリア！おめでとうございます！</h2>' : '<p>まだクリア条件を満たしていません。</p>'}
    `;
    updatePhotoGrid(data.photo);
  }

  function updatePhotoGrid(photo) {
    const photoGrid = document.querySelector('.photo-grid');
    if (photoGrid) {
      const photoItem = document.createElement('div');
      photoItem.className = 'photo-item';
      photoItem.innerHTML = `
        <img src="${photo.image_url}" class="photo-image" alt="Uploaded photo">
        <p class="photo-similarity">類似度: ${(photo.similarity * 100).toFixed(2)}%</p>
      `;
      photoGrid.insertBefore(photoItem, photoGrid.firstChild);
    }
  }
});