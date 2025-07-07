import LinkedinLogo from "../assets/Linkedin.svg"
import GithubLogo from "../assets/Github.svg"
import "../index.css"


function LinkedIcon ({image="string", certurl="string", alttitle="string"}) {
    return (
       <div><a href= {certurl} target="_blank" rel="noopener noreferrer">
        <img className = "socialmedia-icon"
            src= {image}
            alt = {alttitle}/> </a>
        </div>
    )
}

export default function SocialMedia () {
    return (
        <div className="socialmedia-wrapper">
            <LinkedIcon
                alttitle={"LinkedIn icon"}
                image={LinkedinLogo}
                certurl={"https://www.linkedin.com/in/rachel-soon4332/"}
            />
            <LinkedIcon
                alttitle={"GitHub icon"}
                image={GithubLogo}
                certurl={"https://github.com/s00ni"}
            />
        </div>
    )
}
