json.array!(@beans) do |bean|
  json.extract! bean, :id, :name, :category, :jan_code, :price, :special, :notes, :notification, :growing_region, :processing_method, :flavor, :body, :acidity, :complementary_flavors
  json.url bean_url(bean, format: :json)
end
