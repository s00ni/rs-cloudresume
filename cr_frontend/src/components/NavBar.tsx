import Logo from "../assets/RACHEL SOON.svg"
import {useState} from 'react'

function Hamburger () {
    return (
        <>
            <div className="hamburger">
                <div className="burger burger1" />
                <div className="burger burger2" />
                <div className="burger burger3" />
            </div>
        </>
    )
}

export default function Navbar() {

    const [hamburgerOpen, setHamburgerOpen] = useState(false);

    const toggleHamburger = () =>{
        setHamburgerOpen (!hamburgerOpen)
    }

    return (
        <div className= "site-nav">
            <div className="nav-wrapper">
                <div><a href="#top"><img src={Logo} alt="Rachel Soon Logo"/></a></div>
                <div>
                    <div className="hamburger" onClick={toggleHamburger}>
                        <Hamburger/> 
                    </div>
                    <nav>
                        <p><a href="#experience">EXPERIENCE</a></p>
                        <p><a href="#education">EDUCATION</a></p>
                        <p><a href="#skills">SKILLS</a></p>
                        <p><a href="#certifications">CERTIFICATIONS</a></p>
                    </nav>
                </div>
            </div>
            {hamburgerOpen && (
                <div className="stackedmenu">
                    <ul>
                        <p><a href="#experience">EXPERIENCE</a></p>
                        <p><a href="#education">EDUCATION</a></p>
                        <p><a href="#skills">SKILLS</a></p>
                        <p><a href="#certifications">CERTIFICATIONS</a></p>
                    </ul>
                </div>
            )}
        </div>
    )
}

