class VibesController < ApplicationController
  include Timestamp

  def immediate
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      api = WatsonTwitterInsightsApi.new(q_parser.query)
      assembler = JsonAssembler.new(api.get, q_parser)
      render json: assembler.json
    end
  end

  def gradual
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      BackgroundJobsController.run(q_parser)
      render json: q_parser
   end
  end

  def cached
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      assembler = JsonAssembler.new({}, q_parser)
      render json: assembler.json
    end
  end

  private

    def check_params
      params.permit(:q, :range,
                    :seconds, :minutes, :hours, :days, :weeks, :months, :years,
                    :location, :stats, :since, :from,
                    :action)
    end

    def handle_jsonp(data)
      cb = params['callback']
      if cb
        cb + '(' + data.to_json + ');'
      else
        data
      end
    end
end