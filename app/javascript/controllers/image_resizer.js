// image_resizer.js

document.addEventListener('DOMContentLoaded', function() {
  const imageUpload = document.getElementById('imageUpload');
  if (imageUpload) {
    imageUpload.addEventListener('change', function(event) {
      const file = event.target.files[0];
      if (file) {
        resizeAndUploadImage(file);
      }
    });
  }
});

  function resizeAndUploadImage(file) {
      const img = new Image();
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');

      img.onload = function() {
          const MAX_WIDTH = 600; // サイズを調整
          const MAX_HEIGHT = 600;
          let width = img.width;
          let height = img.height;

          // アスペクト比を保ちながらリサイズ
          if (width > height) {
              if (width > MAX_WIDTH) {
                  height *= MAX_WIDTH / width;
                  width = MAX_WIDTH;
              }
          } else {
              if (height > MAX_HEIGHT) {
                  width *= MAX_HEIGHT / height;
                  height = MAX_HEIGHT;
              }
          }

          canvas.width = width;
          canvas.height = height;
          ctx.drawImage(img, 0, 0, width, height);
          
          // リサイズされた画像データURLを取得
          const resizedDataUrl = canvas.toDataURL('image/jpeg');
          
          // サーバーにアップロード
          uploadImage(resizedDataUrl);
      };

      img.src = URL.createObjectURL(file);
  }

  function uploadImage(dataUrl) {
      fetch('/your-upload-endpoint', {
          method: 'POST',
          body: JSON.stringify({ image: dataUrl }),
          headers: { 'Content-Type': 'application/json' }
      }).then(response => {
          if (response.ok) {
              console.log('Image uploaded successfully');
          } else {
              console.error('Image upload failed');
          }
      });
  }