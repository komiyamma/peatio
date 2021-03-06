# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      module NamedParams
        extend ::Grape::API::Helpers

        params :market do
          requires :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
        end

        params :order do
          requires :side,
                   type: String,
                   values: { value: %w(sell buy), message: 'market.order.invalid_side' },
                   desc: -> { V2::Entities::Order.documentation[:side] }
          requires :volume,
                   type: { value: BigDecimal, message: 'market.order.non_decimal_volume' },
                   values: { value: -> (v){ v.try(:positive?) }, message: 'market.order.non_positive_volume' },
                   desc: -> { V2::Entities::Order.documentation[:volume] }
          optional :ord_type,
                   type: String,
                   values: { value: -> { Order::TYPES}, message:  'market.order.invalid_type' },
                   default: 'limit',
                   desc: -> { V2::Entities::Order.documentation[:type] }
          given ord_type: ->(val) { val == 'limit' } do
            requires :price,
                     type: { value: BigDecimal, message: 'market.order.non_decimal_price' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'market.order.non_positive_price' },
                     desc: -> { V2::Entities::Order.documentation[:price] }
          end
        end

        params :order_id do
          requires :id,
                   type: { value: Integer, message: 'market.order.non_integer_id' },
                   allow_blank: { value: false, message: 'market.order.empty_id' },
                   desc: -> { V2::Entities::Order.documentation[:id] }
        end

        params :trade_filters do
          optional :limit,
                   type: { value: Integer, message: 'market.trade.non_integer_limit' },
                   values: { value: 1..1000, message: 'market.trade.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned trades. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'market.trade.non_integer_page' },
                   allow_blank: { value: false, message: 'market.trade.empty_page' },
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :timestamp,
                   type: { value: Integer, message: 'market.trade.non_integer_timestamp' },
                   allow_blank: { value: false, message: 'market.trade.empty_timestamp' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                        "If set, only trades executed before the time will be returned."
          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'market.trade.invalid_order_by' },
                   default: 'desc',
                   desc: "If set, returned trades will be sorted in specific order, default to 'desc'."
        end
      end
    end
  end
end
