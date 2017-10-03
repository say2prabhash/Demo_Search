<%@ WebHandler Language="C#" Class="MainHandler" %>

using System;
using System.Web;
using System.Collections.Generic;
using Nest;

public class MainHandler:IHttpHandler

{
    public bool IsReusable { get; }
    public void ProcessRequest(HttpContext context)
    {
        string jsonString = String.Empty;
        List<string> dataList = new List<string>();
        HttpContext.Current.Request.InputStream.Position = 0;
        using (System.IO.StreamReader inputStream =
        new System.IO.StreamReader(HttpContext.Current.Request.InputStream))
        {
            jsonString = inputStream.ReadToEnd();
            System.Web.Script.Serialization.JavaScriptSerializer jSerialize =
                new System.Web.Script.Serialization.JavaScriptSerializer();
            var search = jSerialize.Deserialize<HotelSearch>(jsonString);

            if (search != null)
            {

                string to = search.To;


                var response = EsClient.InitailizeElasticClient().Search<Hotel>(s=>s
                .Index("hotel")
                .Type("search").AnalyzeWildcard(true)
                .Query(q => q.Match(t => t.Field("_id").Query(to))));
                if (response != null)
                {
                    foreach (var hit in response.Hits)
                    {
                        var data = new Hotel();
                        data.Name = hit.Source.Name.ToString();
                        dataList.Add(data.Name);
                    }

                }

            }
            context.Response.Write(jSerialize.Serialize(dataList));
        }

    }
}
                