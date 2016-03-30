mappings =

  sku:
    supplier_id: 'supplier_id'
    # drop_ship_fee: 'other.fee'
    supplier_name: 'supplier_name'
    product_id: 'other.product_id'
    product_sku: 'other.product_sku'
    warranty: 'meta.warranty'
    condition: 'meta.condition'
    details: 'details'
    manufacturer: 'manufacturer_name'
    brand_name: 'brand_name'
    # case_pack_quantity: ''
    country_of_origin: 'shipping_from'
    product_last_update: 'other.product_updated_at'
    item_id: 'other.item_id'
    item_sku: 'identifier'
    # mpn: ''
    upc: 'other.upc'
    item_name: 'selection_text'
    item_weight: 'weight'
    # ship_alone: ''
    # ship_freight: ''
    ship_weight: 'meta.shipping_weight'
    ship_cost: 'shipping_price'
    # max_ship_single_box: ''
    # map: ''
    price: 'supply_price'
    # custom_price: ''
    # prepay_price: ''
    # street_price: ''
    msrp: 'msrp'
    qty_avail: 'quantity'
    stock: 'discontinued'
    # est_avail: ''
    # pending_order_quantity: ''
    # qty_on_order: ''
    item_last_update: 'other.updated_at'
    # item_discontinued_date: ''
    categories: 'other.categories'
    attributes: 'meta.attributes'
    image_file: 'other.image'
    # image_width: ''
    # image_height: ''
    additional_images: 'other.additional_images'
    # folder_paths: ''
    # is_customized: ''

  product:
    title: 'title'
    description: 'content'

  doba: [
    'supplier_id'
    'drop_ship_fee'
    'supplier_name'
    'product_id'
    'product_sku'
    'title'
    'warranty'
    'description'
    'condition'
    'details'
    'manufacturer'
    'brand_name'
    'case_pack_quantity'
    'country_of_origin'
    'product_last_update'
    'item_id'
    'item_sku'
    'mpn'
    'upc'
    'item_name'
    'item_weight'
    'ship_alone'
    'ship_freight'
    'ship_weight'
    'ship_cost'
    'max_ship_single_box'
    'map'
    'price'
    'custom_price'
    'prepay_price'
    'street_price'
    'msrp'
    'qty_avail'
    'stock'
    'est_avail'
    'pending_order_quantity'
    'qty_on_order'
    'item_last_update'
    'item_discontinued_date'
    'categories'
    'attributes'
    'image_file'
    'image_width'
    'image_height'
    'additional_images'
    'folder_paths'
    'is_customized'
  ]

module.exports = mappings
