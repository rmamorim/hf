Hf::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  match 'boletos/gera_mes/:year/:month/(:day)' => 'boletos#gera_mes',
    :constraints => {
    :year => /(19|20)\d\d/,
    :month => /[01]?\d/,
    :day => /[0-3]?\d/}


  match 'recebidos_cef_mes/:year/:month/(:day)' => 'recebidos_cef_mes#myshow',
    :constraints => {
    :year => /(19|20)\d\d/,
    :month => /[01]?\d/,
    :day => /[0-3]?\d/}

  match 'faturamento/:year/:month(/:day)' => 'faturamento#myshow',
    :constraints => {
    :year => /(19|20)\d\d/,
    :month => /[01]?\d/,
    :day => /[0-3]?\d/}


  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  match 'notas/new/:id'  => 'notas#new'
  match 'vendas/cadastra/:id'  => 'vendas#cadastra'
  match 'vendas/:id/novo_grupo_promissorias'  => 'vendas#novo_grupo_promissorias'
  match 'boletos/:id/choice'  => 'boletos#choice'
  match 'boletos/:id/choice_novo'  => 'boletos#choice_novo'
  match 'boletos/gera_avulsos'  => 'boletos#gera_avulsos'
  match 'boletos/processa_gera_avulsos'  => 'boletos#processa_gera_avulsos'

  match 'boletos/:id/gera_boleto_manual_vincendo'  => 'boletos#gera_boleto_manual_vincendo'
  match 'boletos/:id/gera_boleto_manual_vencido'  => 'boletos#gera_boleto_manual_vencido'
  match 'boletos/:id/new_com_juros'  => 'boletos#new_com_juros'
  match 'boletos/:id/new_sem_juros'  => 'boletos#new_sem_juros'
  match 'boletos/:id/pagamento'  => 'boletos#pagamento'
  match 'boletos/:id/pagar_boleto'  => 'boletos#pagar_boleto'
  match 'idxpoupancas/calcula'  => 'idxpoupancas#calcula'
  match 'promissorias/:id/pagamento'  => 'promissorias#pagamento'
  match 'promissorias/:id/pagar_promissoria'  => 'promissorias#pagar_promissoria'
  
  match 'reports/gnucash'  => 'reports#gnucash'
  match 'reports/gnucash2'  => 'reports#gnucash2'
  match 'reports/etiquetas'  => 'reports#etiquetas'
  match 'reports/espelho'  => 'reports#espelho'
  match 'reports/espelho2'  => 'reports#espelho2'
  match 'reports/etiquetas_iptu'  => 'reports#etiquetas_iptu'
  match 'reports/pagamentos_por_area'  => 'reports#pagamentos_por_area'

  match 'home/backup'  => 'home#backup'
  match 'home/restore'  => 'home#restore'
  
  match 'teste/index'  => 'teste#index'
  match 'teste/areac'  => 'teste#gera_areac'

  resources :areas, :parcelas, :inadimplencia, :notas, :retorno
  resources :pessoas, :vendas, :categorias


  resources :compradores do
    member do
      get 'destroy'
    end
    collection do
    end
  end


  # resources :teste do
  #   member do
  #     get 'gera_areac'
  #   end
  #   collection do
  #   end
  # end

  resources :promissorias do
    member do
    end
    collection do
    end
  end

  resources :vendas do
    member do
      put 'novo_grupo_promissorias'
    end
    collection do
    end
  end


  resources :lotes do
    member do
      get 'extrato'
      get 'imprime_jogo_inicial'
      get 'imprime_parcelas_atrasadas'
    end
    collection do
      get 'vendas'
      get 'notas'
    end
  end

  resources :boletos do
    member do
      get 'gera_mes'
      put 'pagamento'
      #	 put 'new_com_juros'
      #	 put 'new_sem_juros'
    end
    collection do
    end
  end

  resources :idxpoupancas do
    member do
      #      put 'calcula'
    end
    collection do
      #      get 'calcula'
    end
  end




  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  
end
