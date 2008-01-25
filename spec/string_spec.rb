require File.dirname(__FILE__) + '/spec_helper'

describe String, 'to_decoded_unicode' do
  GIVEN = %q{
\u003Ctr class="text_message message user_129553" id="message_48995200" style="display: none"\u003E
  \u003Ctd class="person"\u003E\u003Cspan\u003EBrandon K.\u003C/span\u003E\u003C/td\u003E
  \u003Ctd class="body"\u003E\u003Cdiv\u003Etesting\u003C/div\u003E\u003C/td\u003E
\u003C/tr\u003E
}
  EXPECTED = %q{
<tr class="text_message message user_129553" id="message_48995200" style="display: none">
  <td class="person"><span>Brandon K.</span></td>
  <td class="body"><div>testing</div></td>
</tr>
}
  
  
  before do
  end
  
  it "should convert unicode entities to their string equivelants" do
    '\u003c'.to_decoded_unicode.should == '<'
  end
  
  it "should convert all instances" do
    GIVEN.to_decoded_unicode.should == EXPECTED
  end
  
end