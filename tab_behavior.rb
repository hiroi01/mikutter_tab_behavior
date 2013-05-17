# -*- coding: utf-8 -*-

Plugin.create :tab_behavior do
	@tab_info = Hash.new { |hash, key|
		hash[key] = {}
	}
	@last_active_tab = nil

	command(:tab_behavior_set_default_tab,
		name: 'デフォルトタブに設定',
		condition: lambda{ |opt| true },
		visible: true,
		role: :tab) do |opt|
			h = UserConfig[:tab_behavior_default_tab].dup
			h[opt.widget.parent.slug] =  opt.widget.slug
			UserConfig[:tab_behavior_default_tab] = h
	end

	on_gui_child_activated do |i_parent, i_child, by_toolkit|
		if i_parent.is_a?(Plugin::GUI::Tab) and i_child.is_a?(Plugin::GUI::Timeline)
			@last_active_tab = i_parent
		end
	end

	on_boot do |service|
		if not UserConfig[:tab_behavior_default_tab].is_a? Hash
			UserConfig[:tab_behavior_default_tab] = {}
		end
		UserConfig[:tab_behavior_default_tab].each_value do |tab_slug|
			@tab_info[tab_slug][:self].active! if @tab_info[tab_slug]
		end
	end

    on_tab_created do |i_tab|
		if @last_active_tab
			@tab_info[i_tab.slug][:last_active] = @last_active_tab.slug
		else
			@tab_info[i_tab.slug][:last_active] = nil
		end
		@tab_info[i_tab.slug][:self] = i_tab
		@last_active_tab = i_tab
	end

	on_gui_destroy do |i_widget|
		if @tab_info[i_widget.slug]
				@tab_info[@tab_info[i_widget.slug][:last_active]][:self].active! if @tab_info[@tab_info[i_widget.slug][:last_active]][:self]
			@tab_info.delete(i_widget.slug)
		end

		if i_widget.is_a? Plugin::GUI::Pane
			h = UserConfig[:tab_behavior_default_tab].dup
			h.delete(i_widget.slug)
			UserConfig[:tab_behavior_default_tab] = h
		end
	end

end

