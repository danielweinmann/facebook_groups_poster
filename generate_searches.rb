require 'dotenv'
Dotenv.load

require 'csv'
require 'countries/global'
require 'cities'

Cities.data_path = File.expand_path('../', __FILE__) + "/cities/"

@country_names = []
@city_names = []
@continents = ["Europe", "Asia", "North America", "Australia"]

ISO3166::Country.codes.each do |country_name|
  country = Country[country_name.to_sym]
  next unless @continents.include?(country.continent)
  @country_names << country.translation('en')
  country.unofficial_names.each do |name|
    @country_names << name
  end
  country.unofficial_names.each do |name|
    @country_names << name
  end
  next unless country.cities?
  country.cities.each do |city_array|
    city = city_array[1]
    next unless city.population && city.population > 200000
    @city_names << city.name
  end
end

@searches = []
@country_names.each do |name|
  @searches << "#{ENV["SEARCH_PREFIX"]} #{name}"
end
@city_names.each do |name|
  @searches << "#{ENV["SEARCH_PREFIX"]} #{name}"
end
@searches.uniq!

CSV.open(File.expand_path('../', __FILE__) + "/searches.csv", "w") do |csv|
  @searches.each do |search|
    csv << [search]
  end
end
