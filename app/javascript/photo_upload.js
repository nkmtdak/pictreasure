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
      .then(response => {
        console.log('Raw response:', response);
        return response.text();
      })
      .then(text => {
        console.log('Response text:', text);
        return JSON.parse(text);
      })
      .then(data => {
        if (data.success) {
          uploadResult.innerHTML = '<div class="success-message"><h3>アップロード成功</h3></div>';
          uploadResult.innerHTML += '<p>類似度を計算中...</p>';
          
          // 類似度チェックを開始
          checkSimilarity(data.photo.id);
        } else {
          throw new Error(data.errors ? data.errors.join(', ') : 'アップロードに失敗しました');
        }
      })
      .catch(error => {
        console.error('Detailed error:', error);
        uploadResult.innerHTML = `<div class="error-message">エラーが発生しました: ${error.message}</div>`;
      });
    });
  }

  function checkSimilarity(photoId, element = null) {
    const checkInterval = setInterval(() => {
      fetch(`/photos/${photoId}/check_similarity`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      .then(response => {
        console.log('Raw similarity response:', response);
        return response.text();
      })
      .then(text => {
        console.log('Similarity response text:', text);
        return JSON.parse(text);
      })
      .then(data => {
        if (data.similarity !== null) {
          clearInterval(checkInterval);
          if (element) {
            // チャレンジ履歴の類似度を更新
            element.textContent = `類似度: ${(data.similarity * 100).toFixed(2)}%`;
          } else {
            // 新しくアップロードされた写真の類似度を更新
            updateSimilarityDisplay(data);
          }
        }
      })
      .catch(error => {
        console.error('Detailed error checking similarity:', error);
      });
    }, 2000); // 2秒ごとにチェック
  }

  function updateSimilarityDisplay(data) {
    similarityResult.innerHTML = `
      <p>類似度: ${(data.similarity * 100).toFixed(2)}%</p>
      ${data.cleared ? '<h2 class="success-message">チャレンジクリア！おめでとうございます！</h2>' : '<p class="info-message">まだクリア条件を満たしていません。</p>'}
    `;
    updatePhotoGrid(data.photo);
  }

  // 既存の写真の類似度をチェックする関数
  function checkExistingSimilarities() {
    document.querySelectorAll('.photo-item').forEach(item => {
      const similaritySpan = item.querySelector('.similarity');
      if (similaritySpan && similaritySpan.textContent.includes('計算中')) {
        const photoId = item.dataset.photoId;
        if (photoId) {
          checkSimilarity(photoId, similaritySpan);
        }
      }
    });
  }

  function updatePhotoGrid(photo) {
    const photoGrid = document.querySelector('.photo-grid');
    if (photoGrid) {
      const photoItem = document.createElement('div');
      photoItem.className = 'photo-item';
      photoItem.dataset.photoId = photo.id;
      photoItem.innerHTML = `
        <img src="${photo.image_url}" class="photo-image" alt="Uploaded photo">
        <div class="photo-info">
          <span class="upload-date">${new Date().toLocaleString()}</span><br>
          <span class="username">ユーザー名: ${photo.user_username}</span>
          <span class="similarity">類似度: ${(photo.similarity * 100).toFixed(2)}%</span>
        </div>
      `;
      photoGrid.insertBefore(photoItem, photoGrid.firstChild);
    }
  }

  // ページロード時に既存の写真の類似度をチェック
  checkExistingSimilarities();
});