import React, { Component } from 'react'
import { Router, Route, hashHistory } from 'react-router-dom'

import Requester from './Requester'
import Engineer from './Engineer'
import Home from './Home'
// import Mint from './Mint'
import Transfer from './Transfer'
import Marketplace from './Marketplace'
import Claims from './Claims'
import Disclaimer from './Disclaimer'

class Main extends Component {
	render() {
		return (
			<div className="content">
				<Route exact path='/' component={Home} />
				<Route path='/Requester' render={() => <Requester />} />
				<Route path='/Engineer' render={() =>  <Engineer />} />
				<Route path='/Marketplace' render={() => <Marketplace />} />
				<Route path='/Disclaimer' render={() => <Disclaimer />} />
				<Route exact path='/Transfer' render={() =>  <Transfer web3={this.props.web3} Onyx={this.props.Onyx} />} />
			</div>
		)
	}
}

// <Route exact path='/Mint' render={() =>      <Mint     web3={this.props.web3} Onyx={this.props.Onyx} />} />

export default Main