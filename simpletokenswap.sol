// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import ERC20 interface for token interaction
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import Uniswap V3 ISwapRouter interface
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

// Define the contract
contract SimpleTokenSwap {

    ISwapRouter public immutable swapRouter;

    // Define the WETH token address (could vary by network)
    address public constant WETH9 = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Constructor that initializes the Uniswap V3 router address
    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    // Swap function: Swaps an exact input amount of tokens for as many output tokens as possible
    function swapExactInputSingle(
        address tokenIn,         // Address of the token to swap from
        address tokenOut,        // Address of the token to swap to
        uint256 amountIn,        // Amount of input token
        uint256 amountOutMin,    // Minimum amount of output token to accept (slippage control)
        address recipient        // Address to receive the swapped tokens
    ) external returns (uint256 amountOut) {

        // Transfer `amountIn` of tokenIn from the sender to this contract
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Approve the Uniswap router to spend the input tokens on behalf of this contract
        IERC20(tokenIn).approve(address(swapRouter), amountIn);

        // Set the parameters for the swap using the exactInputSingle method of ISwapRouter
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,                  // The token being swapped
                tokenOut: tokenOut,                // The token to receive
                fee: 3000,                         // The pool fee (e.g., 0.3%)
                recipient: recipient,              // Who receives the swapped tokens
                deadline: block.timestamp + 15,    // Transaction deadline, prevents frontrunning
                amountIn: amountIn,                // Amount of input tokens
                amountOutMinimum: amountOutMin,    // Minimum acceptable output amount
                sqrtPriceLimitX96: 0               // No price limit
            });

        // Execute the swap and return the output amount
        amountOut = swapRouter.exactInputSingle(params);
    }
}
