# サービス名: [らんてくん おすすめ記事](https://x.com/runtekn_rec_art)
### RUNTEQ現役・卒業生〜講師陣の高評価記事を、Xでお知らせします。(毎日19時 & 土日祝12時)
 ![bot](https://github.com/user-attachments/assets/4972e51c-8cdd-45e9-ba44-c0af41e3e5fd)

# なぜこのサービスを作りたいのか？
エンジニアや志望者が記事を書くのは、自身の理解を深めるためではあるものの裏では大変な労力がかかります。<br>
それを支えるモチベーションの1つにしてもらえるよう、本サービスを設計・開発しました。

# 機能
1. ユーザー登録: Mattermost API
    - Qiita, Zenn, x ユーザー名
        - 登録: 紹介対象
        - 空更新: 対象外
2. 記事取得/更新: Qiita, Zenn API
    - 「いいね数/公開期間」を投稿基準にかけて、高評価記事か判別
3. 記事投稿/拡散: X API
    - 高評価記事のうち、投稿回数が少ないものを優先してランダムに投稿
    - APIが成功したら、投稿回数を更新
- 2~3: 繰り返し処理
    - Sidekiq scheduler: 定期ジョブ
    - BugSnag: エラー監視

# 目的
エンジニアや志望者にとって、
1. 技術記事がもっと身近になる
     - まず読む習慣をつくる （読むだけでも充分偉い！）
     - 書くハードルを下げる （周りに書いている人がいると相談できる。最初はまさかりとか怖い）
2. 良記事&筆者がもっと注目される
     - 就活生の後押し
     - エンジニアデビュー後のキャリアのために
     - 過去バズった良記事がまた知られるように (せっかく頑張って書いた記事も、人目に触れなくなるのは早い)

1~2のために、モデルになるような高評価記事をプッシュ通知します。<br>
またこれは裏目的ですが、

3.  RUNTEQコミュニティ 活性化
     - 共通の話題はやっぱり技術
     - 記事を通して誰かを知るきっかけ、話題のきっかけ

になればいいな、とも思っています。<br>
結局、大変な時に支えてくれるのは仲間ですからね。

# 使用技術
1. Ruby on Rails APIモード
     - ruby 3.3.3
     - rails 7.1.3
     - Sidekiq
     - BugSnag
2. Heroku
     - Dyno
     - PostgreSQL
     - Redis
3. Mattermost API
4. Qiita API, Zenn API
5. X API

# ER図
<img width="2244" alt="ER図" src="https://github.com/user-attachments/assets/fd2c59d2-e6a7-48fe-affd-07b4729356fa">

# 登録方法
1. Mattermost に /runtekun と入力します。
2. 登録フォームを選択して送信します。
![register](https://github.com/user-attachments/assets/7b02baa5-793c-4c99-a14a-50a25d9ba680)
