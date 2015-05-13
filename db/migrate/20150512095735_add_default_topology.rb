class AddDefaultTopology < ActiveRecord::Migration
  def up
    unless Topology.default
      Topology.create!(
        name: 'Default topology',
        graph: <<-YAML.strip_heredoc
          ---
          name: HV Network
          children:
          - name: MV Network
            children:
            - name: 'LV #1'
            - name: 'LV #2'
            - name: 'LV #3'
        YAML
      )
    end
  end

  def down
    default = Topology.default
    default && default.destroy
  end
end
