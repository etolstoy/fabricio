require 'fabricio/networking/build_request_model_factory'
require 'fabricio/networking/network_client'
require 'fabricio/models/build'

module Fabricio
  module Service
    # Service responsible for fetching different Build information
    class BuildService

      # Initializes a new BuildService object.
      #
      # @param organization_id_provider [Fabricio::Networking::OrganizationIdProvider]
      # @param network_client [Fabricio::Networking::NetworkClient]
      # @return [Fabricio::Service::BuildService]
      def initialize(organization_id_provider, network_client)
        @request_model_factory = Fabricio::Networking::BuildRequestModelFactory.new(organization_id_provider)
        @network_client = network_client
      end

      # Obtains the list of all application builds
      #
      # @param app_id [String] Application identifier
      # @return [Array<Fabricio::Model::Build>]
      def all(app_id)
        request_model = @request_model_factory.all_builds_request_model(app_id)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['instances'].map do |hash|
          Fabricio::Model::Build.new(hash)
        end
      end

      # Obtains a specific build for a specific application
      #
      # @param app_id [String] Application identifier
      # @param version [String] Build version. E.g. '4.0.1'.
      # @param build_number [String] Build number. E.g. '39'.
      # @return [Fabricio::Model::Build]
      def get(app_id, version, build_number)
        request_model = @request_model_factory.get_build_request_model(app_id, version, build_number)
        response = @network_client.perform_request(request_model)
        Fabricio::Model::Build.new(JSON.parse(response.body)['instances'].first)
      end

      # Obtains an array of top versions for a given app
      #
      # @param app_id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @return [Array<String>]
      def top_versions(app_id, start_time, end_time)
        request_model = @request_model_factory.top_versions_request_model(app_id, start_time, end_time)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['builds']
      end
    end
  end
end
