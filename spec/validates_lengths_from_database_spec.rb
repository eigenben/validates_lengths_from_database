require "spec_helper"

RSpec.describe ValidatesLengthsFromDatabase do

  LONG_ATTRIBUTES = {
    :string_1 => "123456789",
    :string_2 => "123456789",
    :text_1 => "123456789",
    :date_1 => Date.today,
    :integer_1 => 123456789,
    :decimal_1 => 123456789.01,
    :float_1 => 123456789.01
  }

  SHORT_ATTRIBUTES = {
    :string_1 => "12",
    :string_2 => "12",
    :text_1 => "12",
    :date_1 => Date.today,
    :integer_1 => 123,
    :decimal_1 => 12.34,
    :float_1 => 12.34
  }

  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    validates_lengths_from_database :limit => 255
  end

  context "Model without associated table" do
    specify "defining validates_lengths_from_database should not raise an error" do
      expect {
        class InvalidTableArticle < ActiveRecord::Base
          self.table_name = "articles_invalid"
          validates_lengths_from_database
        end
      }.not_to raise_error
    end
  end

  context "Model without a table yet" do
    before do
      class LazyTableArticle < ActiveRecord::Base
        self.table_name = "articles_lazy"
        validates_lengths_from_database
      end
    end

    context "before the table is created" do
      specify "should fail to create records" do
        expect { LazyTableArticle.new }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context "after the table is created" do
      before do
        ActiveRecord::Schema.define do
          create_table :articles_lazy, :force => false do |t|
            t.string :string_1, :limit => 5
          end
        end
      end

      after do
        ActiveRecord::Schema.define do
          drop_table :articles_lazy
        end
      end

      context "an article with long attributes" do
        before { @article = LazyTableArticle.new(LONG_ATTRIBUTES.slice(:string_1)); @article.valid? }

        specify "should not be valid" do
          expect(@article).not_to be_valid
        end
      end

      context "an article with short attributes" do
        before { @article = LazyTableArticle.new(SHORT_ATTRIBUTES.slice(:string_1)); @article.valid? }

        specify "should be valid" do
          expect(@article).to be_valid
        end
      end
    end
  end

  context "Model without validates_lengths_from_database" do
    before do
      class ArticleValidateAll < ActiveRecord::Base
        self.table_name = "articles"
      end
    end

    context "an article with overloaded attributes" do
      before { @article = ArticleValidateAll.new(LONG_ATTRIBUTES); @article.valid? }

      it "should be valid" do
        expect(@article).to be_valid
      end
    end
  end

  context "Model with validates_lengths_from_database" do
    before do
      class ArticleValidateAll < ActiveRecord::Base
        self.table_name = "articles"
        validates_lengths_from_database
      end

      class ArticleValidateText < ActiveRecord::Base
        self.table_name = "articles"
        validates_lengths_from_database :only => [:string_1]
      end
    end

    context "an article with overloaded attributes" do
      before { @article = ArticleValidateAll.new(LONG_ATTRIBUTES); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on all string/text attributes" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
        expect(@article.errors["text_1"].join).to match(/too long/) if small_text_limits?
        expect(@article.errors["decimal_1"].join).to match(/less than/)
      end
    end

    context "inheritance" do
      before do
        class ArticleValidateChild < ApplicationRecord
          self.table_name = "articles"
          validates_lengths_from_database :only => [:string_1]
        end
        class ArticleValidateChildOverwrite < ArticleValidateChild
          validate_lengths_from_database_options[:only] << :string_2
        end
        class ArticleWithoutValidations < ApplicationRecord
          self.table_name = "articles"
          validates_lengths_from_database :only => []
        end
      end

      it "should inherit the validation options from the parent" do
        @article = ArticleValidateChild.new(LONG_ATTRIBUTES)
        @article.valid?
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).not_to match(/too long/)
      end

      it "should allow changing the validation options of child" do
        @article = ArticleValidateChildOverwrite.new(LONG_ATTRIBUTES)
        @article.valid?
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
      end
    end

    context "an article with short attributes" do
      before { @article = ArticleValidateAll.new(SHORT_ATTRIBUTES); @article.valid? }

      it "should be valid" do
        expect(@article).to be_valid
      end
    end

    if postgresql?
      context "an article with with string array attribute" do
        before { @article = ArticleValidateAll.new(:array_1 => %w(1 2 3 4 5 6 7 8 9 10)); @article.valid? }

        it "should be valid" do
          expect(@article).to be_valid
        end
      end
    end
  end

  context "Model with validates_lengths_from_database :limit => 5" do
    before do
      class ArticleValidateLimit < ActiveRecord::Base
        self.table_name = "articles_high_limit"
        validates_lengths_from_database :limit => 5
      end
    end

    context "an article with overloaded attributes" do
      before { @article = ArticleValidateLimit.new(LONG_ATTRIBUTES); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on all string/text attributes" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
        expect(@article.errors["text_1"].join).to match(/too long/)
      end
    end

    context "an article with short attributes" do
      before { @article = ArticleValidateLimit.new(SHORT_ATTRIBUTES); @article.valid? }


      it "should be valid" do
        expect(@article).to be_valid
      end
    end
  end

  context "Model with validates_lengths_from_database :limit => {:string => 5, :text => 100}" do
    before do
      class ArticleValidateSpecificLimit < ActiveRecord::Base
        self.table_name = "articles_high_limit"
        validates_lengths_from_database :limit => {:string => 5, :text => 100}
      end
    end

    context "an article with string_1 that is too many characters" do
      before { @article = ArticleValidateSpecificLimit.new(LONG_ATTRIBUTES); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on all string/text attributes" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
        expect(@article.errors["text_1"]).not_to be_present
        expect(@article.errors["decimal_1"]).not_to be_present
      end
    end

    context "an article with string_1 that is too many bytes, but few enough characters" do
      before do
        @article = ArticleValidateSpecificLimit.new(
          LONG_ATTRIBUTES.merge(:string_1 => "😎😎😎😎", :string_2 => "👍👍👍👍")
        )

        @article.valid?
      end

      it "should be valid" do
        expect(@article).to be_valid
      end
    end

    context "an article with text_1 that is too many characters" do
      before do
        @article = ArticleValidateSpecificLimit.new(LONG_ATTRIBUTES.merge(:text_1 => "a"*101))
        @article.valid?
      end

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on all string/text attributes" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
        expect(@article.errors["text_1"].join).to match(/too long/)
        expect(@article.errors["decimal_1"]).not_to be_present
      end
    end

    context "an article with text_1 that is too many bytes, but few enough characters" do
      before do
        @article = ArticleValidateSpecificLimit.new(LONG_ATTRIBUTES.merge(:text_1 => "👍"*99))
        @article.valid?
      end

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on all string/text attributes" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"].join).to match(/too long/)
        expect(@article.errors["text_1"].join).to match(/too long/)
        expect(@article.errors["decimal_1"]).not_to be_present
      end
    end
  end

  context "Model with validates_lengths_from_database :only => [:text_1], :limit => {:text => 10}" do
    before do
      class ArticleValidateOnlyText < ActiveRecord::Base
        self.table_name = "articles_high_limit"
        validates_lengths_from_database :only => [:text_1], :limit => {:text => 10}
      end
    end

    context "an article with a length equal to max, but a bytesize greater than" do
      before { @article = ArticleValidateOnlyText.new(:text_1 => "😎"*10); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end
    end
  end

  context "Model with validates_lengths_from_database :only => [:decimal_1]" do
    before do
      class ArticleValidateDecimal < ActiveRecord::Base
        self.table_name = "articles"
        validates_lengths_from_database :only => [:decimal_1]
      end
    end

    # decimal_1 is DECIMAL(5,2), which holds -999.99 through 999.99
    [999.99, -999.99, 0].each do |value|
      it "should accept #{value}" do
        expect(ArticleValidateDecimal.new(:decimal_1 => value)).to be_valid
      end
    end

    it "should reject values too large for the column" do
      article = ArticleValidateDecimal.new(:decimal_1 => 1000)
      expect(article).not_to be_valid
      expect(article.errors["decimal_1"].join).to match(/less than 1000/)
    end

    it "should reject values too small for the column" do
      article = ArticleValidateDecimal.new(:decimal_1 => -1000)
      expect(article).not_to be_valid
      expect(article.errors["decimal_1"].join).to match(/greater than -1000/)
    end
  end

  context "Model with validates_lengths_from_database :only => [:string_1, :text_1]" do
    before do
      class ArticleValidateOnly < ActiveRecord::Base
        self.table_name = "articles"
        validates_lengths_from_database :only => [:string_1, :text_1]
      end
    end

    context "an article with long attributes" do
      before { @article = ArticleValidateOnly.new(LONG_ATTRIBUTES); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on only string_1 and text_1" do
        expect(@article.errors["string_1"].join).to match(/too long/)
        expect(@article.errors["string_2"]).to be_empty
        expect(@article.errors["text_1"].join).to match(/too long/) if small_text_limits?
        expect(@article.errors["decimal_1"]).to be_empty
      end
    end

    context "an article with short attributes" do
      before { @article = ArticleValidateOnly.new(SHORT_ATTRIBUTES); @article.valid? }

      it "should be valid" do
        expect(@article).to be_valid
      end
    end
  end

  context "Model with validates_lengths_from_database :except => [:string_1, :text_1]" do
    before do
      class ArticleValidateExcept < ActiveRecord::Base
        self.table_name = "articles"
        validates_lengths_from_database :except => [:string_1, :text_1]
      end
    end

    context "an article with long attributes" do
      before { @article = ArticleValidateExcept.new(LONG_ATTRIBUTES); @article.valid? }

      it "should not be valid" do
        expect(@article).not_to be_valid
      end

      it "should have errors on columns other than string_1 and text_1 only" do
        expect(@article.errors["string_1"]).to be_empty
        expect(@article.errors["text_1"]).to be_empty
        expect(@article.errors["decimal_1"].join).to match(/less than/)
        expect(@article.errors["string_2"].join).to match(/too long/)
      end
    end

    context "an article with short attributes" do
      before { @article = ArticleValidateOnly.new(SHORT_ATTRIBUTES); @article.valid? }

      it "should be valid" do
        expect(@article).to be_valid
      end
    end
  end

  if mysql?
    context "MySQL's default column limits" do
      before do
        class ArticleValidateMysqlDefaults < ActiveRecord::Base
          self.table_name = "articles_high_limit"
          validates_lengths_from_database
        end
      end

      it "should limit VARCHAR(255) columns to 255 characters" do
        expect(ArticleValidateMysqlDefaults.new(:string_1 => "😎" * 255)).to be_valid
        expect(ArticleValidateMysqlDefaults.new(:string_1 => "a" * 256)).not_to be_valid
      end

      it "should limit TEXT columns to 65,535 bytes" do
        expect(ArticleValidateMysqlDefaults.new(:text_1 => "a" * 65_535)).to be_valid
        expect(ArticleValidateMysqlDefaults.new(:text_1 => "😎" * 16_384)).not_to be_valid
      end
    end
  end

  context "options passed to validates_lengths_from_database" do
    it "should not be modified" do
      only = [:string_1]
      limit = {"string" => 3}
      options = {"only" => only, "limit" => limit}

      klass = stub_const("ArticleWithSharedOptions", Class.new(ActiveRecord::Base) do
        self.table_name = "articles"
        validates_lengths_from_database(options)
      end)
      klass.validate_lengths_from_database_options[:only] << :string_2

      expect(options).to eq("only" => [:string_1], "limit" => {"string" => 3})
      expect(only).to eq([:string_1])
    end

    it "should accept a limit hash with string keys" do
      klass = stub_const("ArticleWithStringLimitKeys", Class.new(ActiveRecord::Base) do
        self.table_name = "articles_high_limit"
        validates_lengths_from_database("limit" => {"string" => 3})
      end)

      article = klass.new(:string_1 => "1234")
      expect(article).not_to be_valid
      expect(article.errors["string_1"].join).to match(/too long/)
    end
  end

  context "i18n support for bytesize validation messages" do
    before do
      class ArticleValidateI18n < ActiveRecord::Base
        self.table_name = "articles_high_limit"
        validates_lengths_from_database :only => [:text_1], :limit => {:text => 5}
      end
    end

    after do
      I18n.backend.reload!
    end

    it "should use the bundled English message" do
      article = ArticleValidateI18n.new(:text_1 => "a" * 10)
      article.valid?
      expect(article.errors["text_1"]).to eq(["is too long (maximum is 5 bytes)"])
    end

    it "should use an application-provided translation" do
      I18n.backend.eager_load!
      I18n.backend.store_translations(:en, errors: { messages: { too_long_bytes: { one: "ist zu lang (maximal 1 Byte)", other: "ist zu lang (maximal %{count} Bytes)" } } })

      article = ArticleValidateI18n.new(:text_1 => "a" * 10)
      article.valid?
      expect(article.errors["text_1"]).to eq(["ist zu lang (maximal 5 Bytes)"])
    end
  end

end
