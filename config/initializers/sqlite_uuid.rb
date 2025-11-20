# Enable UUID extension for SQLite
ActiveRecord::Base.connection.execute("SELECT load_extension('mod_spatialite')") rescue nil
