declare variable $local:devices :=  doc("devices.xml")/devices;

declare function local:render-device($device) {
   <div>
      <table>
        <tr><th>Title</th><td>{$device/title/string()}</td></tr>
        <tr><th>Code</th><td>{$device/code/string()}</td></tr>
        <tr><th>Manufacturer</th><td>{$device/manufacturer/string()}</td></tr>
        <tr><th>Type</th><td>{$device/type/string()}</td></tr>
        <tr><th>Product</th><td>{ for $link in $device/product
                                    return 
                                       <div><a href="{$link}">{$link/string()}</a></div>
                                   }</td></tr>
        <tr><th>Datasheet</th><td>{ for $link in $device/datasheet
                                    return 
                                       if (starts-with($link,"http"))
                                       then <div><a href="{$link}">{$link/string()}</a></div>
                                       else <div><a href="docs/{$link}">{$link/string()}</a></div>
                                   }</td></tr>
        <tr><th>Tutorial</th><td>{ for $link in $device/tutorial
                                    return 
                                       <div><a href="{$link}">{$link/@source/string()}</a></div>
                                   }</td></tr>
        <tr><th>Video</th><td>{ for $link in $device/video
                                    return 
                                       <div><a href="{$link}">{$link/@source/string()}</a></div>
                                   }</td></tr>
        <tr><th>Library</th><td>{ for $link in $device/library
                                    return 
                                       <div><a href="{$link}">{$link/@title/string()}</a></div>
                                   }</td></tr>
        <tr><th>Voltage</th><td>{$device/voltage/string()}</td></tr>
        <tr><th>Current Consumption</th><td>{$device/current/string()}</td></tr>
        <tr><th>Interface</th><td>{$device/interface/string()}</td></tr>

        {if ($device/type = "sensor")
         then (
         <tr><th>Measures</th><td>{$device/measures/string()}</td></tr>,
         <tr><th>Principle</th><td>{$device/principle/node()}</td></tr>,
         <tr><th>Breakout</th><td>{ for $link in $device/breakout
                                    return 
                                       <div><a href="{$link}">{$link/@source/string()}</a></div>
                                   }</td></tr>,
  
        <tr><th>Precision</th><td>{$device/precision/string()}</td></tr>,
        <tr><th>Accuracy</th><td>{$device/accuracy/string()}</td></tr>,
        <tr><th>Response time</th><td>{$device/response/string()}</td></tr>
        ) 
        else if ($device/type = "MCU")
        then (
          <tr><th>Clock Speed </th><td>{$device/clockspeed/string()}</td></tr>,
          <tr><th>Memory</th><td>{$device/memory/string()}</td></tr>,
          <tr><th>Interface</th><td>{$device/interface/string()}</td></tr> 
        )
        else ()
        
        }
        {if (exists($device/requires))
         then <tr><th>Requires</th><td>{for $u in $device/requires return <span><a href="?code={$u}">{$u/string()}</a></span>}</td></tr>
         else ()
        }
        {if (exists($device/includes))
         then <tr><th>Includes</th><td>{for $u in $device/includes return <span><a href="?code={$u}">{$u/string()}</a></span>}</td></tr>
         else ()
        }
        {if (exists($device/usewith))
         then <tr><th>Use with</th><td>{for $u in $device/usewith return <span><a href="?code={$u}">{$u/string()}</a></span>}</td></tr>
         else ()
        }
        <tr>
         <th>Pinout</th>
         <td>
           <table>
            <tr><td colspan="3">{$device/pinout/order/string()}</td></tr>
             {for $pin at $i in $device/pinout/pin
              return
                <tr><th>{$i}</th><td>{$pin/@label/string()}</td><td>{$pin/string()}</td></tr>
             }
           </table>
         </td>
        </tr>
        <tr><th>Discussion</th><td>{$device/discussion/node()}</td></tr>
        <tr><th>Arduino code</th>
             <td>{for $link in $device/arduinoCode
                  return 
                       <div><a href="{$link}">{$link/@source/string()}</a></div>
                  }
             </td>
        </tr>
     </table>
   </div>
};


declare function local:render-device-index() {
   <div>               
        <table class="sortable">
        <tr><th>Type</th><th>Code</th><th>Manufacture</th><th>Title</th></tr>
        {
         for $device in $local:devices/device
         order by $device/type descending, $device/code
         return
           <tr>
             <td>{$device/type/string()}</td>
             <th> <a href="?code={$device/code}">{$device/code/string()} </a></th>
             <td>{$device/manufacturer/string()}</td> 
             <td>{$device/title/string()}</td>
           </tr>
        }
        </table>
    </div>    
};


let $code := request:get-parameter("code",())
let $body :=
    if (exists($code))
    then let $device := $local:devices/device[code=$code]
         return local:render-device($device)
    else local:render-device-index()
let $serialize := util:declare-option( "exist:serialize", "method=xhtml media-type=text/html") 

return
<html>
    <head>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
            <script type="text/javascript" src="sorttable.js"></script> 

    </head>
    <body>
        <div style="font-size:14pt; margin-left:20pt">
             <h2><a href="?">Devices</a>  </h2>
             {$body}
         </div>
   </body>
</html>
