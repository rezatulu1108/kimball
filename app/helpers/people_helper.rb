module PeopleHelper
  def address_fields_to_sentence(person)
    [person.address_1, person.address_2, person.city, person.state, person.postal_code].reject{|i| i.blank? }.join(", ")
  end

  def human_device_type_name(device_id)
    begin; Logan::Application.config.device_mappings.rassoc(device_id)[0].to_s; rescue; "Unknown/No selection"; end
  end

  def human_connection_type_name(connection_id)
    mappings = {:phone => "Phone with data plan", 
      :home_broadband => "Home broadband (cable, DSL)", 
      :other => "Other", 
      :public_computer => "Public computer", 
      :public_wifi => "Public wifi"
    }
    
    begin; mappings[Logan::Application.config.connection_mappings.rassoc(connection_id)[0]]; rescue; "Unknown/No selection"; end
  end

  def sendToMailChimp(person)
    if person.email_address.present? and person.verified.start_with?("Verified")
        begin
          mailchimpSend = Gibbon.list_subscribe({
            :id => Logan::Application.config.cut_group_mailchimp_list_id, 
            :email_address => new_person.email_address, 
            :double_optin => 'false', 
            :update_existing => 'true',
            :merge_vars => {:FNAME => person.first_name, 
              :LNAME => person.last_name, 
              :MMERGE3 => person.geography_id, 
              :MMERGE4 => person.postal_code, 
              :MMERGE5 => person.participation_type, 
              :MMERGE6 => person.voted, 
              :MMERGE7 => person.called_311, 
              :MMERGE8 => person.primary_device_description, 
              :MMERGE9 => person.secondary_device_id, 
              :MMERGE10 => person.secondary_device_description, 
              :MMERGE11 => person.primary_connection_id, 
              :MMERGE12 => person.primary_connection_description, 
              :MMERGE13 => person.primary_device_id, 
              :MMERGE14 => person.preferred_contact_method}
              })
        rescue Gibbon::MailChimpError => e
          Rails.logger.fatal("[People->sendToMailChimp] fatal error sending #{person.id} to Mailchimp: #{e.message}")
        end
      end
  end

end