// 作品一覧データ。新しいWebサイトを作ったら、この配列に1件追加するだけで
// トップページの一覧に反映されます。
//
// status: "live"        公開中
//         "in-progress"  制作中
//         "planned"      作成予定

const PROJECTS = [
  {
    title: "スプラトゥーン3 プラベ募集Bot",
    description: "Discordのプラベ募集で、「ノ」「行く」などの発言をGemini APIが判定して参加者を自動管理。誤判定しても人が直せる設計、運用しながら追加した締切・引き継ぎ・ゲスト追加、1GBのVPSでの常時稼働までをまとめた開発記録。",
    tags: ["Python", "discord.py", "Gemini API", "SQLite"],
    url: "/spl3-private/",
    status: "live",
    linkLabel: "開発記録を読む →",
  },
  {
    title: "スプラトゥーン3 ブキルーレットBot",
    description: "WindowsでDiscord Botを開発し、ConoHa VPSのUbuntuへ配置。条件設定パネルの実装からsystemdによる常時稼働までをまとめた開発記録。",
    tags: ["TypeScript", "discord.js", "Ubuntu", "ConoHa VPS"],
    url: "/spl3-roulette/",
    status: "live",
    linkLabel: "開発記録を読む →",
  },
  {
    title: "ストロベリー R.",
    description: "足利市のヘアサロンのWebサイト。店長がスマホからNews・Staffを更新できる管理画面付き。",
    tags: ["HTML", "CSS", "JavaScript", "PHP"],
    url: "/strawberry/",
    status: "live",
  },
];

