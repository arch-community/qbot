# frozen_string_literal: true

##
# Job to update the Arch Linux repositories
class UpdateArchReposJob < ApplicationJob
  def perform
    ArchRepos::DBCache.instance.update_all
    ArchRepos::Index.instance.populate_from_global_cache
  end
end
