require 'schema_dev/gemfiles'

describe SchemaDev::Gemfiles do

  it "copies listed files" do
    config = get_config(ruby: %W[1.9.3 2.1.5], activerecord: %W[4.0 4.1], db: %W[sqlite3 postgresql])
    in_tmpdir do
      expect(SchemaDev::Gemfiles.build(config)).to be_truthy
      expect(relevant_diff(config, "gemfiles")).to be_empty
    end
  end

  it "only copies files once" do
    config = get_config(ruby: %W[1.9.3 2.1.5], activerecord: %W[4.0 4.1], db: %W[sqlite3 postgresql])
    in_tmpdir do
      expect(SchemaDev::Gemfiles.build(config)).to be_truthy
      expect(SchemaDev::Gemfiles.build(config)).to be_falsey
    end
  end

  def relevant_diff(config, dir)
    src = SchemaDev::Templates.root + dir
    diff = `diff -rq #{src} #{dir} 2>&1`.split("\n")

    # expect copy not to have entry for activerecord not in config
    diff.reject!{ |d| d =~ %r[Only in #{src}: activerecord-(.*)] and not config.activerecord.include? $1 }

    # expect copy not to have entry for db not in config
    diff.reject!{ |d| d =~ %r[Only in #{src}.*: Gemfile.(.*)] and not config.db.include? $1 }
  end

end


