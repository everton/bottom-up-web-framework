App.map_routes do |routes|
  routes.get 'users/:id', controller: :users, action: :show

  routes.root controller: :users, action: :index
end
