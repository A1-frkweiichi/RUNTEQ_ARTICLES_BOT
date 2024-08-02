# サービス名: [らんてくん おすすめ記事](https://x.com/runtekn_rec_art)
### RUNTEQ現役・卒業生〜講師陣の高評価記事を、Xでお知らせします。(毎日19時 & 土日祝12時)
<p align="center">
  <a href="https://x.com/runtekn_rec_art" target="_blank">
    <img src="https://github.com/user-attachments/assets/4972e51c-8cdd-45e9-ba44-c0af41e3e5fd" alt="x_bot">
  </a>
</p>

# なぜこのサービスを作りたいのか？
エンジニアや志望者が記事を書くのは、自身の理解を深めるためではあるものの、裏では大変な労力がかかっています。<br>
それを支えるモチベーションの1つにしてもらえるよう、本サービスを設計・開発しました。

# 機能
1. ユーザー登録: `Mattermost API`
    - Qiita, Zenn, X ユーザー名
        - 登録: 紹介対象
        - 空更新: 対象外
2. 記事取得/更新: `Qiita API`, `Zenn API`
    - 「いいね数/公開年数」を投稿基準にかけて、高評価記事か判別
3. 記事投稿: `X API`
    - 高評価記事のうち、投稿回数が少ないものを優先してランダムに投稿
    - APIが成功したら、投稿回数を更新
- 2~3: バックグラウンドジョブ
    - ジョブ管理: `Sidekiq scheduler`
    - エラー監視: `BugSnag`

# 目的
エンジニアや志望者にとって、
1. 技術記事がもっと身近になる
     - まず読む習慣をつくる （読むだけでも充分偉い！）
     - 書くハードルを下げる （周りに書いている人がいると相談できる。最初はまさかりとか怖い）
2. 良記事&筆者がもっと注目される
     - 就活の後押し
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
<p align="center">
 <img width="600" alt="ER図20240803" src="https://github.com/user-attachments/assets/1e3d7a91-7310-4bec-8657-af20f963110e">
</p>

# 登録方法
1. Mattermostに`/runtekun`と入力します。
   - 予測変換機能から`/runtekun-recommends-articles`コマンド（登録フォーム）を選択して送信します。
2. `Qiita`もしくは`Zenn`ユーザー名を登録すると、記事が紹介対象になります。
   - 空で更新すると、記事が紹介対象から外れます。
   - `X`ユーザー名を登録すると、記事紹介時にメンションされます。
3. 登録ボタンを押して完了します。
![register](https://github.com/user-attachments/assets/5fb8b994-442e-4ce6-be33-54449b3f95b6)

# 投稿サンプル
<p align="center">
  <img src="https://github.com/user-attachments/assets/030206da-755a-4f73-a8ea-d0346f0c6230" alt="sample_post">
</p>
 
