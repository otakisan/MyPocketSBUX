json.array!(@press_releases) do |press_release|
  json.extract! press_release, :id, :fiscal_year, :press_release_sn, :title, :url
  json.url press_release_url(press_release, format: :json)
end
