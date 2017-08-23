namespace :db do
  namespace :second_base do

    namespace :create do
      task :all => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:create:all'].execute }
      end
    end

    task :create => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:create'].execute }
    end

    namespace :drop do
      task :all => ['db:load_config']  do
        SecondBase.on_base { Rake::Task['db:drop:all'].execute }
      end
    end

    namespace :purge do
      task :all => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:purge:all'].execute }
      end
    end

    task :purge => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:purge'].execute }
    end

    task :migrate => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:migrate'].execute }
    end

    namespace :migrate do

      task :redo => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:redo'].execute }
      end

      task :up => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:up'].execute }
      end

      task :down => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:down'].execute }
      end

      task :status => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:status'].execute }
      end

    end

    task :rollback => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:rollback'].execute }
    end

    task :forward => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:forward'].execute }
    end

    task :abort_if_pending_migrations => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:abort_if_pending_migrations'].execute }
    end

    task :version => [:environment, 'db:load_config'] do
      SecondBase.on_base { Rake::Task['db:version'].execute }
    end

    namespace :schema do

      task :load => [:environment, 'db:load_config', :check_protected_environments] do
        SecondBase.on_base { Rake::Task['db:schema:load'].execute }
      end

      namespace :cache do

        task :dump => [:environment, 'db:load_config'] do
          SecondBase.on_base { Rake::Task['db:schema:cache:dump'].execute }
        end

      end

    end

    namespace :structure do

      task :dump => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:structure:dump'].execute }
      end

      task :load => [:environment, 'db:load_config'] do
        SecondBase.on_base { Rake::Task['db:structure:load'].execute }
      end

    end

    namespace :test do

      task :purge => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:purge'].execute }
      end

      task :load_schema => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:load_schema'].execute }
      end

      task :load_structure => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:load_structure'].execute }
      end

      task :prepare => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:prepare'].execute }
      end

    end

  end
end

%w{
  create:all create drop:all purge:all purge
  migrate migrate:status abort_if_pending_migrations
  schema:load schema:cache:dump structure:dump structure:load
  test:purge test:load_schema test:load_structure test:prepare
}.each do |name|
  task = Rake::Task["db:#{name}"] rescue nil
  next unless task && SecondBase::Railtie.run_with_db_tasks?
  task.enhance do

    if name.in? ['create',
      'migrate', 'migrate:status', 'abort_if_pending_migrations',
      'schema:load', 'schema:cache:dump',
      'structure:dump', 'structure:load']

      Rake::Task["environment"].invoke
    end

    Rake::Task["db:load_config"].invoke
    Rake::Task["db:second_base:#{name}"].invoke
  end
end
