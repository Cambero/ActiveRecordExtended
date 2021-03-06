# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Contains SQL Queries" do
  let(:contains_array_regex)      { /\"people\"\.\"tag_ids\" @> '\{1,2\}'/ }
  let(:contains_hstore_regex)     { /\"people\"\.\"data\" @> '\"nickname\"=>"Dan"'/ }
  let(:contains_jsonb_regex)      { /\"people\"\.\"jsonb_data\" @> '\{"nickname\":\"Dan"}'/ }
  let(:contained_in_array_regex)  { /\"people\"\.\"tag_ids\" <@ '\{1,2\}'/ }
  let(:contained_in_hstore_regex) { /\"people\"\.\"data\" <@ '\"nickname\"=>"Dan"'/ }
  let(:contained_in_jsonb_regex) { /\"people\"\.\"jsonb_data\" <@ '\{"nickname\":\"Dan"}'/ }
  let(:contains_equals_regex)     { /\"people\"\.\"ip\" >>= '127.0.0.1'/ }
  let(:equality_regex)            { /\"people\"\.\"tags\" = '\{"?working"?\}'/ }

  describe ".where.contains(:column => value)" do
    it "generates the appropriate where clause for array columns" do
      query = Person.where.contains(tag_ids: [1, 2]).to_sql
      expect(query).to match_regex(contains_array_regex)
    end

    it "generates the appropriate where clause for hstore columns" do
      query = Person.where.contains(data: { nickname: "Dan" }).to_sql
      expect(query).to match_regex(contains_hstore_regex)
    end

    it "generates the appropriate where clause for jsonb columns" do
      query = Person.where.contains(jsonb_data: { nickname: "Dan" }).to_sql
      expect(query).to match_regex(contains_jsonb_regex)
    end

    it "generates the appropriate where clause for hstore columns on joins" do
      query = Tag.joins(:person).where.contains(people: { data: { nickname: "Dan" } }).to_sql
      expect(query).to match_regex(contains_hstore_regex)
    end

    it "allows chaining" do
      query = Person.where.contains(tag_ids: [1, 2]).where(tags: ["working"]).to_sql
      expect(query).to match_regex(contains_array_regex)
      expect(query).to match_regex(equality_regex)
    end

    it "generates the appropriate where clause for array columns on joins" do
      query = Tag.joins(:person).where.contains(people: { tag_ids: [1, 2] }).to_sql
      expect(query).to match_regex(contains_array_regex)
    end
  end
end
