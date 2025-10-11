local config = function()

-- init.lua
require("dbee").setup({
  sources = {
    require("dbee.sources").MemorySource:new({
      {
        name = "Sushi DB (local)",
        type = "postgres",
        -- ホストから接続（docker-compose で 5432 を公開している）
        url = "postgres://sushi_user:password@localhost:5432/sushi_db?sslmode=disable",
      },
      -- コンテナ内でNeovimを使う場合は以下（サービス名解決）
      -- {
      --   name = "Sushi DB (in docker network)",
      --   type = "postgres",
      --   url = "postgres://sushi_user:password@postgres:5432/sushi_db?sslmode=disable",
      -- },
    }),
  },
})

end
return config
