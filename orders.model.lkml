connection: "looker-private-demo"
label: "(1) Looker Delight - General"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: order_items {
 # sql_always_where: ${status} != 'Cancelled' ;;

# always_filter: {
#   filters: [order_items.status: "-Cancelled"]
# }
 # fields: [-users.users_set*]
  description: "One stop shop for my orders"
  label: "Corporate Orders"
  view_label: "Orders"
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
   # fields: [users.users_set*]  #

  view_label: "Corporate Users"  # benefit

    type: left_outer                                #note the default join and types of join
    sql_on: ${order_items.user_id} = ${users.id} ;; # ideally join as this view to the corresponding view to connect to
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on:  ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
} # How to decide what is going to be my base explore

explore: inventory_items {
  description: "Inventory and product information"
  label: "Inventory and Products"
  view_label: "Inventory"

  join: products {
    view_label: "Products"
    type: left_outer
    sql_on:  ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}
