# アプリケーション名
PICTREASURE(PICT+TREASUREの造語)

# アプリケーション概要
お題の写真を撮影してくるゲーム。

# URL
https://pictreasure.onrender.com
# テスト用アカウント
ベーシック認証ID:admin
ベーシック認証Pass: 2222

# 利用方法
ログインして適当なチャレンジを選択して「チャレンジスタート」する。
お題の写真が表示されているページに遷移するのでそれと同じような写真を撮影してアップロードする。
類似度が70%以上あったらチャレンジクリアーとなる。

# 開発環境 
Ruby onRails -7.0.0  
html&css(scss)  
javascript

# 実装した機能
ユーザー管理機能
[![Image from Gyazo](https://i.gyazo.com/6d978b1c7023fbd93904d5acf67bd50f.gif)](https://gyazo.com/6d978b1c7023fbd93904d5acf67bd50f)
チャレンジ成功
[![Image from Gyazo](https://i.gyazo.com/fddb100cce1a4180793ebd4388d615c7.gif)](https://gyazo.com/fddb100cce1a4180793ebd4388d615c7)
チャレンジ失敗
[![Image from Gyazo](https://i.gyazo.com/229092b3bac56b1b4a6a8462de409ccb.gif)](https://gyazo.com/229092b3bac56b1b4a6a8462de409ccb)
# アプリケーションを作成した背景
これをアナログでスタッフの目視チェックでおこなっていたゲームカフェがあって、そのアナログチェックの不便さを解消したいと思って作成しました。

# 改善案
・お題ランダム機能を設ける。  
・制限時間表示機能の実装。  

# 制作時間
二週間半

# データベース設計

### User
| フィールド   | 説明                                |
|--------------| --------------------------------- |
| User name    | ユーザーの表示名                     |
| mailaddress  | ユーザーのメールアドレス（ログイン用）   |
| password     | ユーザーのパスワード（ハッシュ化）      |
| role         | ユーザーの役割（例：一般、管理者）      |

### Challenge
| フィールド   | 説明                              |
|--------------|-------------------------------  |
| title        | チャレンジのタイトル               |
| description  | チャレンジの詳細な説明             |
| user_id      |                                |
| clear        |                                |

### Photo
| フィールド      | 説明                                  |
| ------------- | -------------------------------------- |
| user_id       | 写真を投稿したユーザーのID                |
| challenge_id  | 写真が投稿されたチャレンジのID             |
| similarity    | 類似度スコア                            |