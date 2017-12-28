//Cotract um alle Ether aus dem Contract an den Owner zu schicken und den Contract zu löschen
pragma solidity ^0.4.18;

contract mortal
{
	/* Define variable owner of the type address */
	address owner;

	/* This function is executed at initialization and sets the owner of the contract */
	function mortal() public { owner = msg.sender; }

	/* Function to recover the funds on the contract */
	function kill() public
	{
		if (msg.sender == owner) 
		{
			selfdestruct(owner);
		}
		else
		{
			revert();
		}
	}
}
