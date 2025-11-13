namespace :sites do
  desc "Generate additional sites for testing (default: 50)"
  task :generate, [:count] => :environment do |t, args|
    count = (args[:count] || 50).to_i
    
    puts "🏗️  Generating #{count} additional sites..."
    
    # French nuclear site names and locations
    site_prefixes = [
      'Centrale Nucléaire de', 'Site de', 'Station de', 'Centre de',
      'Unité de', 'Installation de', 'Complexe de', 'Base de'
    ]
    
    site_types = [
      'Production', 'Maintenance', 'Contrôle', 'Traitement',
      'Stockage', 'Surveillance', 'Recherche', 'Formation'
    ]
    
    french_cities = [
      'Strasbourg', 'Nantes', 'Montpellier', 'Rennes', 'Reims',
      'Le Havre', 'Saint-Étienne', 'Toulon', 'Grenoble', 'Dijon',
      'Angers', 'Nîmes', 'Villeurbanne', 'Clermont-Ferrand', 'Le Mans',
      'Aix-en-Provence', 'Brest', 'Tours', 'Amiens', 'Limoges',
      'Annecy', 'Perpignan', 'Boulogne-Billancourt', 'Metz', 'Besançon',
      'Orléans', 'Mulhouse', 'Rouen', 'Caen', 'Nancy',
      'Argenteuil', 'Montreuil', 'Saint-Denis', 'Roubaix', 'Tourcoing',
      'Avignon', 'Poitiers', 'Versailles', 'Courbevoie', 'Vitry-sur-Seine',
      'Créteil', 'Colombes', 'Aulnay-sous-Bois', 'Asnières-sur-Seine', 'Rueil-Malmaison',
      'Antibes', 'Cannes', 'Calais', 'Dunkerque', 'Bourges'
    ]
    
    regions = [
      'Nord', 'Sud', 'Est', 'Ouest', 'Centre',
      'Île-de-France', 'Normandie', 'Bretagne', 'Provence', 'Alsace',
      'Lorraine', 'Aquitaine', 'Rhône-Alpes', 'Languedoc', 'Pays de Loire'
    ]
    
    created_count = 0
    
    count.times do |i|
      # Generate unique site data
      prefix = site_prefixes.sample
      city = french_cities.sample
      site_type = site_types.sample
      region = regions.sample
      
      # Create unique code
      city_code = city.gsub(/[^A-Z]/, '')[0..2].upcase
      number = sprintf('%03d', Site.maximum(:id).to_i + i + 1)
      code = "#{city_code}-#{number}"
      
      # Generate site name
      name = if rand(2) == 0
        "#{prefix} #{city}"
      else
        "#{site_type} #{city} #{region}"
      end
      
      # Generate address
      street_number = rand(1..999)
      street_types = ['Rue', 'Avenue', 'Boulevard', 'Place', 'Allée', 'Chemin']
      street_names = [
        'de la République', 'de la Liberté', 'du Général de Gaulle', 'Victor Hugo',
        'Jean Jaurès', 'de la Paix', 'Nationale', 'du Commerce', 'des Arts',
        'de l\'Industrie', 'du Progrès', 'de l\'Innovation', 'Pasteur', 'Voltaire'
      ]
      postal_code = "#{rand(1..95)}#{rand(100..999)}"
      
      address = "#{street_number} #{street_types.sample} #{street_names.sample}, #{postal_code} #{city}"
      
      # Generate description
      descriptions = [
        "Site de production - Zone sécurisée niveau #{rand(1..4)}",
        "Centre technique et administratif",
        "Installation de contrôle et surveillance",
        "Complexe industriel - Accès contrôlé",
        "Base opérationnelle régionale",
        "Station de traitement et maintenance",
        "Centre de formation et recherche",
        "Unité de stockage sécurisé",
        "Site de maintenance préventive",
        "Installation de surveillance automatisée"
      ]
      
      begin
        site = Site.create!(
          name: name,
          code: code,
          address: address,
          description: descriptions.sample,
          active: rand(10) > 0 # 90% active, 10% inactive
        )
        
        created_count += 1
        print "."
      rescue ActiveRecord::RecordInvalid => e
        # Skip duplicates or validation errors
        print "x"
      end
    end
    
    puts "\n"
    puts "✅ Successfully created #{created_count} sites!"
    puts "📊 Total sites in database: #{Site.count}"
    puts "   - Active: #{Site.active.count}"
    puts "   - Inactive: #{Site.where(active: false).count}"
  end
  
  desc "Delete all generated sites (keeps original sites with ID <= 10)"
  task :cleanup => :environment do
    puts "🧹 Cleaning up generated sites..."
    
    generated_sites = Site.where('id > ?', 10)
    count = generated_sites.count
    
    if count > 0
      generated_sites.destroy_all
      puts "✅ Deleted #{count} generated sites"
      puts "📊 Remaining sites: #{Site.count}"
    else
      puts "ℹ️  No generated sites to delete"
    end
  end
end
