import AWSLogo from "../assets/AWS-SAA.png"
import NetLogo from "../assets/Network-Plus.png"
import "../index.css"

export default function Certs () {
    return(
        <div className = "resume-block" style={{borderBottom: "#F7F6FB"}} id= "certifications">
        <p className = "heading-underline">CERTIFICATIONS</p>
        <section className = "cert-icon" style={{borderBottom: "#F7F6FB", display: "flex", paddingTop:"2.5rem", paddingBottom: "3rem", gap: "2.5rem"}}>
            <a href= "https://www.credly.com/badges/8f2d977c-1825-47b4-955f-0deb3586f38d/public_url" target="_blank" rel="noopener noreferrer">
                <img
                    src={AWSLogo}
                    alt="AWS-SAA icon"
                    className="aws-logo"
                />
            </a>
            <a href= "https://www.credly.com/badges/ebc8eeaa-6340-4da9-8455-e8fbf43c6de2/public_url" target="_blank" rel="noopener noreferrer">
                <img
                    src={NetLogo}
                    alt="NetPlus icon"
                    className="net-logo"
                />
            </a>
        </section>
        </div>
    )
}