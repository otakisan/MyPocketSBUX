json.array!(@press_releases) do |press_release|
  json.extract! press_release, :id, :fiscal_year, :press_release_sn, :title, :url
  # モデルのurl列の値が上書きされるので、とりあえずコメントアウト
  # jsonで一本釣りしたいときのurlが欲しい時は、下記が必要だけどどうするか
  #json.url press_release_url(press_release, format: :json)
end
