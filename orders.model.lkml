connection: "looker-private-demo"
label: "(1) Looker Delight - General"

include: "/views/*.view.lkml"
include: "/views/Scenario_B/*.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: order_items {
  view_name: order_items

  #### Applying User Attributes ############
  # access_filter: {
  #   field: users.state
  #   user_attribute: state
  # }

  # access_filter: {
  #   field: users.city
  #   user_attribute: city
  # }
##############################################

  sql_always_where: ${users.state} = '{{ _user_attributes['state']}}' OR ${users.city} = '{{ _user_attributes['city']}}';;

# always_filter: {
#   filters: [order_items.status: "-Cancelled"]
# }
 # fields: [-users.users_set*]
  description: "One stop shop for my orders"
  label: "Corporate Orders"
 # view_label: "Orders"
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

explore: +order_items {}

# explore: pop_cross {view_name: order_items label: "PoP Method 9: Refinement and Cross Join to add to any explore" view_label: "_PoP" #matching the naming used in other examples

#   #To enable pop, you'll paste this join to your explore defition
#   join: pop_support {
#     view_label: "PoP Support - Overrides and Tools" #(Optional) Update view label for use in this explore here, rather than in pop_support view. Some choose to update this to match the view that has the key POP date field.
#     relationship:one_to_one #we are intentionally fanning out, so this should stay one_to_one
#     sql:{% if pop_support.periods_ago._in_query%}LEFT JOIN pop_support on 1=1{%endif%};;#join and fannout data for each prior_period included if and only if lynchpin pivot field (periods_ago) is selected. This extra safety that we dont fire the join if the user selected PoP parameters but didn't actually select a pop pivot field
#   }
#   #(Optionally): Update this always filter to your base date field to encourage a filter.  Without any filter, 'future' periods will be shown when POP is used (because, for example: today's data is/will be technically 'last year' for next year)
#   always_filter: {filters: [order_items.created_date: "before 0 minutes ago"]}
# }
