view: order_items {
  sql_table_name: `looker-private-demo.ecomm.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
   # datatype: timestamp
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: gross_margin {
    label: "Gross Margin"
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
   # datatype: timestamp
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

########## Logistics ##########


  dimension: days_to_process {
    label: "Days to Process"
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN DATE_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN DATE_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }


  dimension: shipping_time {
    label: "Shipping Time" #
    type: number
    sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;; #
  }

  dimension: item_gross_margin_percentage {
    label: "Item Gross Margin Percentage"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    label: "Item Gross Margin Percentage Tier"
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: relational
  }




  #### All Customer Measures Go Here ##################

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: average_days_to_process {
    label: "Average Days to Process"
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    label: "Average Shipping Time"
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

  measure: total_sales_price {
    label: "Total Sales Price" # Also talk about quick help
    type: sum
    sql: ${sale_price} ;;
    drill_fields: [order_id, status, created_date] #
    value_format_name: usd #
  }

  measure: average_sales_price {
    label: "Total Sales Price" # Also talk about quick help
    type: average
    sql: ${sale_price} ;;
    drill_fields: [order_id, status, created_date] #
    value_format_name: usd #
  }

  measure: total_gross_margin {
    description: "Profits based on Order cost - Inventory Cost"
    label: "Total Gross Margin"
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    # drill_fields: [detail*]
    drill_fields: [order_id, status, created_date]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
