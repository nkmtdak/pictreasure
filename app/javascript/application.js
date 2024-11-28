// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./photo_upload"

//ハンバーガーメニュー
document.addEventListener('DOMContentLoaded', function() {
  const menuToggle = document.getElementById('menu-toggle');
  const menuList = document.querySelector('.menu-list');

  menuToggle.addEventListener('click', function() {
    menuList.classList.toggle('active'); // activeクラスをトグル
  });
});

window.onload = function () {
  console.log("JavaScriptが正しく読み込まれました！");
};