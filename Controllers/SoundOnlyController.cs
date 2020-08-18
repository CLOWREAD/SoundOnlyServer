using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace WebAudioServer.Controllers
{

    struct SoundPack
    {
       public long Length;
       public  byte[] Data;

    };

    [Route("api/[controller]")]
    [ApiController]
    public class SoundOnlyController : ControllerBase
    {

        public static Hashtable m_Packs = new Hashtable();
        static Queue<long> m_PackID_Queue = new Queue<long>;
        [Route("/API/SoundOnly/Upload/{UTC}")]
        public async void  Upload(String UTC)
        {
            //var resp = Request;
            //var bodystr = await new StreamReader(resp.Body).ReadToEndAsync();
            var s_UpStream = Request.Body;
            //var s_UpStream = Request.Form.Files.GetFile("soundonly").OpenReadStream();
            byte[] buffer= new byte[1474560] ;

            var position = 0;
            position= await s_UpStream.ReadAsync(buffer, 0, 1474560);
            m_Packs.Add(UTC, new SoundPack()
            {
                Length=position,
                Data=buffer
            });
            long id = Convert.ToInt64(UTC);
            m_PackID_Queue.Enqueue(id);
            if(m_PackID_Queue.Count>256)
            {
                m_PackID_Queue.Dequeue();
            }
        }
        [Route("/API/SoundOnly/Download/{UTC}.wav")]
        public async Task<Stream> Download(String UTC)
        {
            Response.ContentType = "audio/wav";
            var res = new MemoryStream();
            res.SetLength(0);
            res.Seek(0, SeekOrigin.Begin);
            var resp = Request;
            var bodystr =  await new StreamReader( resp.Body).ReadToEndAsync();
            if( m_Packs.ContainsKey(UTC))
            {
                var pack=(SoundPack)m_Packs[UTC];
                Response.ContentLength = pack.Length;
                res.SetLength(pack.Length);
                res.Seek(0, SeekOrigin.Begin);
                res.Write(pack.Data, 0, (int) pack.Length);
                res.Seek(0, SeekOrigin.Begin);
            }
            return res ;
        }
        [Route("/API/SoundOnly/GetQueue")]
        public String ID_Queue()
        {

            return m_PackID_Queue.ToList().ToString(); 
        }
    }
}