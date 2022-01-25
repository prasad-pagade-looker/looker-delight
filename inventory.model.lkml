connection: "looker-private-demo"
label: "(2) Looker Delight - Inventory"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: inventory_items {
  # label: "Product and Inventory Mgmt"
  # description: "Inventory and Product Data"
  join: products {
    view_label: "Products List"
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship:  many_to_one
  }
}
