class NilUser
  def authenticated?
    false
  end

  def id
    nil
  end

  def name
    'Anonymous'
  end

  def admin?
    false
  end

  def gds_editor?
    false
  end

  def can_edit_sites
    {}
  end

  def can_edit_site?(site_to_edit)
    false
  end

  def own_organisation
    nil
  end
end
