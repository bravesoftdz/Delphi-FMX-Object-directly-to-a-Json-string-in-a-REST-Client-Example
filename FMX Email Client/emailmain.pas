unit emailmain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FMX.Edit, FMX.Controls.Presentation, Rest.JSON, Rest.Client,
  Rest.Types, IPPeerClient, Data.Bind.Components,
  Data.Bind.ObjectScope;

type
// create an object Temail which will be converted to a Json String
  Temail = class
    ffrom: string;
    ffrom_address: string;
    fcc: string;
    fto: string;
    fto_address: string;
    fsubject: string;
    fbody: string;
  published
    property from: string read ffrom write ffrom;
    property from_address: string read ffrom_address write ffrom_address;
    property cc: string read fcc write fcc;
    property &to: string read fto write fto;
    property to_address: string read fto_address write fto_address;
    property subject: string read fsubject write fsubject;
    property body: string read fbody write fbody;
  end;

  Tfmmain = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Layout1: TLayout;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Edit3: TEdit;
    Label5: TLabel;
    Edit4: TEdit;
    Label6: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    Label7: TLabel;
    Edit5: TEdit;
    Label8: TLabel;
    Edit6: TEdit;
    StyleBook1: TStyleBook;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    URL: String;
    APIKey: String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmmain: Tfmmain;
  Restrequest: TRestrequest;
  RestClient: TRestClient;
  RestResponse: TRestResponse;

implementation

{$R *.fmx}

procedure Tfmmain.Button1Click(Sender: TObject);
var
  email: Temail; // class to create jsonobject- eliminates a parser
  ContentType: TRestContenttype;
  SendContent: String;
  ResponseContent: String;
  jsonstr: string;
begin
  Memo2.Lines.Clear;
  URL := 'https://YourRestserver';
   email := Temail.Create;
  try
    email.to_address := Edit1.Text;
    email.&to := Edit2.Text;
    email.cc := Edit3.Text;
    email.from := Edit4.Text;
    email.from_address := Edit5.Text;
    email.subject := Edit6.Text;
    email.body := Memo1.Text;
    // Add email object to json string
    jsonstr := TJson.ObjecttoJsonString(email);
    Memo2.Lines.Add('');
    Memo2.Lines.Add(jsonstr);
  finally
    freeandnil(email);
  end;
  //Add encryption here
   SendContent := trim(jsonstr);
  Memo2.Lines.Add('');
  Memo2.Lines.Add('Sending.......');
  Memo2.Lines.Add('');
  begin
    try
     //create the rest components
      RESTClient := TRESTClient.Create(URL);
      RESTrequest := TRESTrequest.Create(self);
      RESTResponse := TRESTResponse.Create(self);
      RESTrequest.Response := RESTResponse;
      RESTrequest.Client := RESTClient;
      APIKey := 'Your key';    //test key
      RESTClient.ContentType := 'text/html';
      RESTClient.Authenticator.Free;

      Contenttype:= ctMULTIPART_ENCRYPTED;
      RESTrequest.Params.AddItem('Authorization', APIKey,
      TRESTRequestParameterKind.pkHTTPHEADER);
      RESTrequest.body.ClearBody;
      RESTrequest.body.Add(SendContent, ContentType);
      RESTrequest.method := TRESTRequestMethod.rmPost;
      try
        // post the encoded message
        RESTrequest.Execute;
        // 200 success!
        if RESTResponse.StatusCode <> 200 then
        begin
          ResponseContent := RESTResponse.Errormessage;
        end
        else
        begin
          // Add Successful message
          ResponseContent := RESTResponse.Content;
          memo2.lines.add('');
          memo2.lines.add('REST-Server response.....');
          Memo2.Lines.Add(ResponseContent);
           end
      except
        on exception: ERESTException do
          ResponseContent := 'Could not connect to Webserver';
        on exception: ERequestError do
          ResponseContent := 'Could not connect to the Internet';
      end;
    finally
      freeandnil(RESTClient);
      freeandnil(RESTrequest);
      freeandnil(RESTResponse);
    end;
    Memo2.GoToTextEnd;
    sleep(500);
    memo2.GoToTextBegin;
  end;
end;

procedure Tfmmain.FormShow(Sender: TObject);
 begin
  Edit1.Text := 'another@anothermail.com'; // to email address
  Edit2.Text := 'A.N Other'; // From
  Edit3.Text := 'whoever@anothermail.com'; // cc
  Edit4.Text := 'A.N Other'; // From
  Edit5.Text := 'another@anothermail.com'; // from Email Address
  Edit6.Text := ' This could be a test email from a  Mobile Phone';// subject
  memo1.Text := 'This is a test email that has been designed to be sent from an Android Phone.'+#13#10+
                'The important confidential email is securely relayed to the hosts email address.' +#13#10+
                'The REST-Server processes the API key based on a Post Rest-connection which is sent ' +#13#10+
                'within the safer and secure Header structure. The REST-Server should be set up as a HTTPS REST-Server.';
  end;
 end.
