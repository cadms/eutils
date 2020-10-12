require 'helper'

class TestEutils < Test::Unit::TestCase
  tool = "eutilstest"
  email = "seouri@gmail.com"
  eutils = Eutils.new(tool, email)
  should "set tool and email at instance creation" do
    assert_equal eutils.tool, tool
    assert_equal eutils.email, email
  end

  should "set tool and email after instance creation" do
    eutils_no_tool_email = Eutils.new
    eutils_no_tool_email.tool = tool
    eutils_no_tool_email.email = email
    assert_equal eutils_no_tool_email.tool, tool
    assert_equal eutils_no_tool_email.email, email
  end

  should "raise runtime error without tool or email" do
    eutils_no = Eutils.new
    assert_raise RuntimeError do
      eutils_no.einfo
    end
  end

  should "get array of db names from EInfo with no parameter" do
    db = eutils.einfo
    assert_equal Array, db.class
    assert_equal true, db.include?("pubmed")
    assert_equal Array, eutils.einfo("").class
    assert_equal Array, eutils.einfo("  ").class
  end

  should "get a hash from EInfo with db parameter" do
    i = eutils.einfo("pubmed")
    assert_equal Hash, i.class
    assert_equal "DbInfo", i.keys.first
    assert_equal "pubmed", i['DbInfo']['DbName']
  end

  should "get a hash from ESearch for a term" do
    r = eutils.esearch("cancer")
    assert_equal Hash, r.class
    assert_equal "cancer", r["TranslationSet"]["Translation"]["From"]
    assert_equal Array, r["IdList"]["Id"].class
  end

  should "get webenv and querykey from EPost for posted ids" do
    ids = [11877539, 11822933, 11871444]
    webenv, querykey = eutils.epost(ids)
    assert_equal 1, querykey
    assert_equal "MCID", webenv.scan(/^(\w{4})/).flatten.first
    webenv, querykey = eutils.epost(ids, "invalid")
    assert_nil querykey
    assert_nil webenv
  end

  should "get a hash from ESummary for posted ids" do
    ids = [11850928, 11482001]
    i = eutils.esummary(ids)
    assert_equal Hash, i.class
    assert_equal ids[0], i['DocSum'][0]['Id'].to_i
  end

  should "get a hash from EFetch for ESearch result" do
    s = eutils.esearch("cancer")
    webenv = s["WebEnv"]
    query_key = s["QueryKey"]
    r = eutils.efetch("pubmed", webenv, query_key)
    assert_equal Hash, r.class
    assert_equal "PubmedArticleSet", r.keys.first
  end

  should "get spelling suggestion for a term" do
    assert_equal "breast cancer", eutils.espell("brest cancr")
    assert_equal "breast cancer", eutils.espell("brest cancer")
    assert_equal "", eutils.espell(" ")
  end

  should "get a hash from Elink" do
    i = eutils.elink([9298984])
    assert_equal Hash, i.class
    assert_equal "9298984", i["LinkSet"]["IdList"]["Id"]
  end

  should "get hash from EGQuery" do
    i = eutils.egquery("autism")
    assert_equal Hash, i.class
    assert_equal "Term", i.keys.sort.first
    assert_equal "eGQueryResult", i.keys.sort.last
    assert_equal "autism", i["Term"]
  end
end
