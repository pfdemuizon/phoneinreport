module StateSelect
  def self.state_options_for_select(options = {})
    none = [ ["Select One...",nil] ]

    states = [
      ["Alabama","AL"],
      ["Alaska","AK"],

      ["American Samoa","AS"],
      ["Arizona","AZ"],
      ["Arkansas","AR"],
      ["California","CA"],
      ["Colorado","CO"],
      ["Connecticut","CT"],

      ["Delaware","DE"],
      ["D.C.","DC"],
      ["Florida","FL"],
      ["Georgia","GA"],
      ["Guam","GU"],
      ["Hawaii","HI"],

      ["Idaho","ID"],
      ["Illinois","IL"],
      ["Indiana","IN"],
      ["Iowa","IA"],
      ["Kansas","KS"],
      ["Kentucky","KY"],

      ["Louisiana","LA"],
      ["Maine","ME"],
      ["Maryland","MD"],
      ["Massachusetts","MA"],
      ["Michigan","MI"],
      ["Minnesota","MN"],

      ["Mississippi","MS"],
      ["Missouri","MO"],
      ["Montana","MT"],
      ["Nebraska","NE"],
      ["Nevada","NV"],
      ["New Hampshire","NH"],

      ["New Jersey","NJ"],
      ["New Mexico","NM"],
      ["New York","NY"],
      ["North Carolina","NC"],
      ["North Dakota","ND"],
      ["Ohio","OH"],

      ["Oklahoma","OK"],
      ["Oregon","OR"],
      ["Pennsylvania","PA"],
      ["Puerto Rico","PR"],
      ["Rhode Island","RI"],
      ["South Carolina","SC"],

      ["South Dakota","SD"],
      ["Tennessee","TN"],
      ["Texas","TX"],
      ["Utah","UT"],
      ["Vermont","VT"],
      ["Virgin Islands","VI"],

      ["Virginia","VA"],
      ["Washington","WA"],
      ["West Virginia","WV"],
      ["Wisconsin","WI"],
      ["Wyoming","WY"]
    ]

    provinces = [
      ["Alberta","AB"],

      ["British Columbia","BC"],
      ["Manitoba","MB"],
      ["Newfoundland","NF"],
      ["New Brunswick","NB"],
      ["Nova Scotia","NS"],
      ["Northwest Territories","NT"],

      ["Nunavut","NU"],
      ["Ontario","ON"],
      ["Prince Edward Island","PE"],
      ["Quebec","QC"],
      ["Saskatchewan","SK"],
      ["Yukon Territory","YT"]
    ]

    other = [
      ["Other","ot"]
    ]

    select_options = []
    select_options += none if options[:include_none]
    select_options += states
    select_options += provinces if options[:include_provinces]
    select_options += other if options[:include_other]
    select_options
  end
end
