# frozen_string_literal: true

shared_context 'with_organization_model' do
  with_model :Organization do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      validates_presence_of :name
      subscriptable
    end
  end
  let!(:organization) { Organization.create(name: 'Flatirons') }
end
