# frozen_string_literal: true

class Admin::Metrics::Measure::OpenedReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def key
    'opened_reports'
  end

  protected

  def perform_total_query
    Report.where(created_at: time_period).count
  end

  def perform_previous_total_query
    Report.where(created_at: previous_time_period).count
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH new_reports AS (
          SELECT reports.id
          FROM reports
          WHERE date_trunc('day', reports.created_at)::date = axis.period
        )
        SELECT count(*) FROM new_reports
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', :start_at::timestamp)::date, date_trunc('day', :end_at::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL
  end
end
